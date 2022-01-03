# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class SessionsController < ApplicationController
  prepend_before_action -> { authentication_check && authorize! }, only: %i[switch_to_user list delete]
  skip_before_action :verify_csrf_token, only: %i[show destroy create_omniauth failure_omniauth]
  skip_before_action :user_device_check, only: %i[create_sso]

  # "Create" a login, aka "log the user in"
  def create
    user = authenticate_with_password
    initiate_session_for(user)

    # return new session data
    render status: :created,
           json:   SessionHelper.json_hash(user).merge(config: config_frontend)
  end

  def create_sso
    raise Exceptions::Forbidden, 'SSO authentication disabled!' if !Setting.get('auth_sso')

    user = begin
      login = request.env['REMOTE_USER'] ||
              request.env['HTTP_REMOTE_USER'] ||
              request.headers['X-Forwarded-User']

      User.lookup(login: login&.downcase)
    end

    raise Exceptions::NotAuthorized, 'Missing SSO ENV REMOTE_USER or X-Forwarded-User header' if login.blank?
    raise Exceptions::NotAuthorized, "No such user '#{login}' found!" if user.blank?

    session.delete(:switched_from_user_id)
    authentication_check_prerequesits(user, 'SSO', {})

    redirect_to '/#'
  end

  def show
    user = authentication_check_only
    raise Exceptions::NotAuthorized, 'no valid session' if user.blank?

    initiate_session_for(user)

    key = "User::authorizations:pwa::#{user.id}"
    linked_accounts = Cache.get(key)
    if !linked_accounts
      linked_accounts = user.authorizations().map{|auth| {uid: auth[:uid], provider: auth[:provider],username: auth[:username]}}
      Cache.write(key, linked_accounts)
    end

    # return current session
    render json: SessionHelper.json_hash(user).merge(config: config_frontend, linked_accounts: linked_accounts, categories: categories)
  rescue Exceptions::NotAuthorized => e

    # CSI pwa automatic account linking info
    auth = session["first_step_login.auth"]
    error = session["first_step_login.error"]
    if auth
      auth_creation_info = { provider: auth[:provider], uid: auth[:uid], info: {email: auth[:info][:email]} }
    else
      auth_creation_info = nil
    end

    render json: {
      first_step_login: {auth: auth_creation_info, error: error},
      error:       e.message,
      config:      config_frontend,
      models:      SessionHelper.models,
      collections: { Locale.to_app_model => Locale.where(active: true) },
      categories: categories
    }
  end

  # "Delete" a login, aka "log the user out"
  def destroy

    reset_session

    # Remove the user id from the session
    @_current_user = nil

    # reset session
    request.env['rack.session.options'][:expire_after] = nil

    render json: {}
  end

  def create_omniauth

    # in case, remove switched_from_user_id
    session[:switched_from_user_id] = nil
    auth = request.env['omniauth.auth']

    if !auth
      # redirect to app
      redirect_to '/'
    end

    # Create a new user or add an auth to existing user, depending on
    # whether there is already a user signed in.
    authorization = Authorization.find_from_hash(auth)

    if isRequestFromCSIpwaLoginPage?
      # if session["first_step_login.auth"] is present, this is the second step
      # of new account creation in CSI custom pwa
      first_step_auth = session["first_step_login.auth"]
      second_step_url = request.env['omniauth.params']['second_step_url']
      if authorization and first_step_auth
        if first_step_auth.provider != auth.provider
          # create authorization of first step provider, and associate with existing user of second step provider
          second_step_auth = Authorization.find_by(uid: auth.uid)
          unless second_step_auth
            session["first_step_login.error"] = {code:"non_existing_account"}
            redirect_to second_step_url
            return
          end
          authorization = Authorization.create_from_hash(first_step_auth, second_step_auth.user)
        end
        session["first_step_login.auth"] = nil
        session["first_step_login.error"] = nil
      end

      if !authorization
        if !first_step_auth
          # ask user confirm
          session["first_step_login.auth"] = auth
          redirect_to second_step_url
          return
        else
          if first_step_auth.provider == auth.provider
            session["first_step_login.auth"] = nil
            session["first_step_login.error"] = nil
            # normal user create
            authorization = Authorization.create_from_hash(auth, current_user)
          else
            session["first_step_login.error"] = {code:"non_existing_account"}
            redirect_to second_step_url
            return
          end
        end

      end
    end

    if !authorization
      authorization = Authorization.create_from_hash(auth, current_user)
    end

    if in_maintenance_mode?(authorization.user)
      redirect_to '/#'
      return
    end

    # set current session user
    current_user_set(authorization.user)

    # log new session
    authorization.user.activity_stream_log('session started', authorization.user.id, true)

    # remember last login date
    authorization.user.update_last_login

    # redirect to app
    if request.env['omniauth.auth']['provider'] == "csimodshib" && request.env["action_dispatch.request.query_parameters"]["origin"]
      redirect_to "#{request.env["action_dispatch.request.query_parameters"]["origin"]}"
    elsif request.env['omniauth.origin']
      redirect_to "#{request.env['omniauth.origin']}"
    else
      redirect_to '/'
    end

  end

  def failure_omniauth
    raise Exceptions::UnprocessableEntity, "Message from #{params[:strategy]}: #{params[:message]}"
  end

  # "switch" to user
  def switch_to_user
    # check user
    if !params[:id]
      render(
        json:   { message: 'no user given' },
        status: :not_found
      )
      return false
    end

    user = User.find(params[:id])
    if !user
      render(
        json:   {},
        status: :not_found
      )
      return false
    end

    # remember original user
    session[:switched_from_user_id] ||= current_user.id

    # log new session
    user.activity_stream_log('switch to', current_user.id, true)

    # set session user
    current_user_set(user)

    render(
      json: {
        success:  true,
        location: '',
      },
    )
  end

  # "switch" back to user
  def switch_back_to_user

    # check if it's a switch back
    raise Exceptions::Forbidden if !session[:switched_from_user_id]

    user = User.lookup(id: session[:switched_from_user_id])
    if !user
      render(
        json:   {},
        status: :not_found
      )
      return false
    end

    # remember current user
    current_session_user = current_user

    # remove switched_from_user_id
    session[:switched_from_user_id] = nil

    # set old session user again
    current_user_set(user)

    # log end session
    current_session_user.activity_stream_log('ended switch to', user.id, true)

    render(
      json: {
        success:  true,
        location: '',
      },
    )
  end

  def available
    render json: {
      app_version: AppVersion.get
    }
  end

  def list
    assets = {}
    sessions_clean = []
    SessionHelper.list.each do |session|
      next if session.data['user_id'].blank?

      sessions_clean.push session
      next if session.data['user_id']

      user = User.lookup(id: session.data['user_id'])
      next if !user

      assets = user.assets(assets)
    end
    render json: {
      sessions: sessions_clean,
      assets:   assets,
    }
  end

  def delete
    SessionHelper.destroy(params[:id])
    render json: {}
  end

  private

  def initiate_session_for(user)
    request.env['rack.session.options'][:expire_after] = 1.year if params[:remember_me]
    session[:persistent] = true
    user.activity_stream_log('session started', user.id, true)
  end

  def config_frontend

    # config
    config = {}
    Setting.select('name, preferences').where(frontend: true).each do |setting|
      next if setting.preferences[:authentication] == true && !current_user

      value = Setting.get(setting.name)
      next if !current_user && (value == false || value.nil?)

      config[setting.name] = value
    end

    # remember if we can switch back to user
    if session[:switched_from_user_id]
      config['switch_back_to_possible'] = true
    end

    # remember session_id for websocket logon
    if current_user
      config['session_id'] = session.id.public_id
    end

    config
  end

  def categories
    {
      service_catalog_items: ServiceCatalogItem.all,
      service_catalog_sub_items: ServiceCatalogSubItem.all,
      assets:     Asset.all
    }
  end

  def isRequestFromCSIpwaLoginPage?
    request.env['omniauth.params'] && request.env['omniauth.params']['app'] == 'pwa' && !request.env['omniauth.params']['second_step_url'].to_s.strip.empty?
  end
end

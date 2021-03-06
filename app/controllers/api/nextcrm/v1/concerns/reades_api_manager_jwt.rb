# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

module Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  extend ActiveSupport::Concern

  included do
    # normalmente sarebbe una basic_auth, che non scatenerebbe il controllo del csfr
    # facendo set del current_user (virtual operator) l'autenticazione sembra provenire da sessione, e da errore il CSFR
    skip_before_action :verify_csrf_token
    # prepend mette in cima alla lista di azioni
    prepend_before_action :check_apiman_jwt
  end

  # check_apiman_jwt viene eseguito come prima action, facendo:
  # - la verifica sull'autenticazione dell'utente usato nell'invocazione delle API da Api Manager
  # - la sostituzione dell'utente usato nell'invocazione delle API da Api Manager con l'utente
  #   virtual agent ("#{application_name}@csi.it").
  # Le successive chiamate di autenticazione e autorizzazione saranno effettuate sul virtual agent
  def check_apiman_jwt
    begin
      log_input_parameters

      # check http basic based authentication
      authenticate_with_http_basic do |username, password|
        request.session_options[:skip] = true # do not send a session cookie
        apilogger.info { "http basic auth check for '#{username}'" }
        if Setting.get('api_password_access') == false
          raise Exceptions::NotAuthorized, 'API password access disabled!'
        end

        auth = Auth.new(username, password)
        if !auth.valid?
          raise Exceptions::NotAuthorized, 'Invalid BasicAuth credentials'
        end

        user = User.identify(username)
        if !user.permissions?('api_manager')
          raise Exceptions::NotAuthorized, "user #{username} must have permission 'api_manager'"
        end
      end

      apilogger.debug " api apimanager jwt ---->  #{request.headers['X-JWT-Assertion']} "

      # return if params[:debug]

      apimanager_raw_jwt = request.headers['X-JWT-Assertion']

      # test_payload = {
      #   'http://wso2.org/claims/organization' => 'poc_nextCRM_team',
      #   'http://wso2.org/claims/role' => ['Internal/subscriber', 'Application/marco.lucchesi_poc_NextCRM_PRODUCTION', 'Internal/everyone'],
      #   'http://wso2.org/claims/applicationtier' => 'Unlimited',
      #   'http://wso2.org/claims/keytype' => 'PRODUCTION',
      #   'http://wso2.org/claims/version' => 'v1', 'iss' => 'wso2.org/products/am',
      #   'http://wso2.org/claims/applicationname' => 'poc_NextCRM',
      #   'http://wso2.org/claims/enduser' => 'marco.lucchesi@carbon.super',
      #   'http://wso2.org/claims/enduserTenantId' => '-1234', 'http://wso2.org/claims/company' => 'CSI',
      #   'http://wso2.org/claims/givenname' => 'Marco',
      #   'http://wso2.org/claims/applicationUUId' => '8f1662b1-767c-45d8-a250-5f05517eb93e',
      #   'http://wso2.org/claims/institution' => 'CSI',
      #   'http://wso2.org/claims/subscriber' => 'marco.lucchesi',
      #   'http://wso2.org/claims/tier' => 'Unlimited',
      #   'http://wso2.org/claims/emailaddress' => 'marco.lucchesi@consulenti.csi.it',
      #   'http://wso2.org/claims/lastname' => 'Lucchesi', 'exp' => 1_615_493_320,
      #   'http://wso2.org/claims/applicationid' => '74', 'http://wso2.org/claims/usertype' => 'APPLICATION',
      #   'http://wso2.org/claims/apicontext' => '/tecno/nextcrm/v1'
      # }
      # apimanager_raw_jwt = JWT.encode test_payload, nil, 'none', { typ: 'JWT' }
      # one line minimal jwt:
      # apimanager_raw_jwt  = JWT.encode( {'http://wso2.org/claims/applicationname' => 'poc_NextCRM'}, nil, 'none', {typ:'JWT'} )
      ###

      decoded_jwt = JWT.decode(apimanager_raw_jwt, nil, false)
      jwt_meta = decoded_jwt[0]
      application_name = jwt_meta['http://wso2.org/claims/applicationname']
      raise Exceptions::NotAuthorized, "http://wso2.org/claims/applicationname in X-JWT-Assertion not found: #{apimanager_raw_jwt}" if !application_name

      # Sostituzione dell'utente usato nell'invocazione delle API da Api Manager con l'utente virtual agent
      app_user = User.find_by(email: "#{application_name.downcase}@csi.it")
      if app_user
        current_user_set(app_user, 'basic_auth')
        user_device_log(app_user, 'basic_auth')
        apilogger.info { "current user setted to #{current_user.email} " }
      else
        apilogger.error { "user not found with X-JWT-Assertion http://wso2.org/claims/applicationname: #{application_name}" }
        raise Exceptions::NotAuthorized, "user not found with X-JWT-Assertion: #{apimanager_raw_jwt}  -  http://wso2.org/claims/applicationname: #{application_name}"
      end
    rescue => e
      apilogger.error e
      raise Exceptions::NotAuthorized
    end
  end

  def log_input_parameters
    apilogger.info { "called path: #{request.filtered_path}" }
    apilogger.info { "input parameters: #{request.filtered_parameters}" }
    # attenzione, RAW_POST_DATA puo' contenere interi file
    trunc_post_payload = truncate(request.env['RAW_POST_DATA'])
    apilogger.debug { "raw input parameters: #{trunc_post_payload}" }
  end

  def truncate(input_text, length = 1000, truncate_string = '...[FILTERED]')
    return '' if !input_text
    # TODO, capire come prendere i primi n caratteri di Faraday::CompositeReadIO durante un multipart.
    # se si esegue #read si ottiene la stringa ma altera il body e remedy non lo recepisce
    return ' filtered multipart data' if input_text.is_a? Faraday::CompositeReadIO

    text = input_text.to_s

    l = length - truncate_string.chars.length
    (text.length > length ? text[0...l] + truncate_string : text).to_s
  end
end

Dir[ Rails.root.join('lib/omniauth/*') ].sort.each do |file|
  if File.file?(file)
    require file
  end
end

Rails.application.config.middleware.use OmniAuth::Builder do

  # twitter database connect
  provider :twitter_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database', {
    client_options: {
      authorize_path: '/oauth/authorize',
      site:           'https://api.twitter.com',
    }
  }

  # facebook database connect
  provider :facebook_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database'

  # linkedin database connect
  provider :linked_in_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database'

  # google database connect
  provider :google_oauth2_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database', {
    client_options: {connection_opts: {proxy: 'http://proxy-srv.csi.it:3128'}},
    authorize_options: {
      access_type:     'online',
      approval_prompt: '',
    }
  }

  # github database connect
  provider :github_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database'

  # gitlab database connect
  provider :gitlab_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database', {
    client_options: {
      site:          'https://not_change_will_be_set_by_database',
      authorize_url: '/oauth/authorize',
      token_url:     '/oauth/token'
    },
  }

  # microsoft_office365 database connect
  provider :microsoft_office365_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database'

  # oauth2 database connect
  provider :oauth2_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database', {
    client_options: {
      site:          'https://not_change_will_be_set_by_database',
      authorize_url: '/oauth/authorize',
      token_url:     '/oauth/token',
    },
  }

  # weibo database connect
  provider :weibo_database, 'not_change_will_be_set_by_database', 'not_change_will_be_set_by_database'

  # SAML database connect
  provider :saml_database

  # CSI SPID (Shibboleth) custom omniauth Strategy
  provider :csimodshib
end

# This fixes issue #1642 and is required for setups in which Zammad is used
# with a reverse proxy (like e.g. NGINX) handling the HTTPS stuff.
# This leads to the generation of a wrong redirect_uri because Rack detects a
# HTTP request which breaks OAuth2.

# This fix / setting causes omniauth callback sent to SP to be static.
# It is commented to permit omniauth to get hostname diynamically from request (as omniauth default)
#OmniAuth.config.full_host = proc {
#  "#{Setting.get('http_type')}://#{Setting.get('fqdn')}"
#}

OmniAuth.config.logger = Rails.logger

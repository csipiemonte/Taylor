class AdvancedSAMLDatabase < OmniAuth::Strategies::SAML
  option :name, 'advanced_saml'

  def initialize(app, *args, &block)

    http_type = Setting.get('http_type')
    fqdn      = Setting.get('fqdn')

    # Use meta URL as entity id/issues as it is best practice.
    # See: https://community.zammad.org/t/saml-oidc-third-party-authentication/2533/13
    entity_id                      = "#{http_type}://#{fqdn}/auth/saml/metadata"
    assertion_consumer_service_url = "#{http_type}://#{fqdn}/auth/saml/callback"

    config  = Setting.get('auth_advanced_saml_credentials') || {}
    options = config.reject { |_k, v| v.blank? }
      .merge(
        attribute_statements:{
          login: ['Shib-Identita-CodiceFiscale'],
          first_name: ['Shib-Identita-Nome'],
          last_name: ['Shib-Identita-Cognome']
        }

        )

    args[0] = options

    super
  end

end

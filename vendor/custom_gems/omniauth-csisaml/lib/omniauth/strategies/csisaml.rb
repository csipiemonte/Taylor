class Csisaml < OmniAuth::Strategies::SAML
  option :name, 'csisaml'

  def initialize(app, *args, &block)

    http_type = Setting.get('http_type')
    fqdn      = Setting.get('fqdn')

    # Use meta URL as entity id/issues as it is best practice.
    # See: https://community.zammad.org/t/saml-oidc-third-party-authentication/2533/13
    entity_id                      = "#{http_type}://#{fqdn}/auth/saml/metadata"
    assertion_consumer_service_url = "#{http_type}://#{fqdn}/auth/saml/callback"

    config = Setting.get('auth_advanced_saml_credentials') || {}

    # cfr. https://intranet.csi.it/web/wp-content/uploads/2021/01/Manuale-uso-integrazione-piattaforma-Shibboleth2.pdf
    options = config.reject { |_k, v| v.blank? }
      .merge(
        attribute_statements: {
          nickname:   ['Shib-Identita-Matricola'], # restituito solo per IAMIDPCSI e IAMIDPCRP
          first_name: ['Shib-Identita-Nome'], # restituito sempre
          last_name:  ['Shib-Identita-Cognome'] # restituito sempre
        }
      )
    args[0] = options

    super
  end
end

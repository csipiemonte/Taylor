class Csisaml < OmniAuth::Strategies::SAML
  # la custom strategy CSI deve chiamarsi 'saml' per funzionare
  # perche' si tratta di autenticazione SAML
  option :name, 'saml'

  def initialize(app, *args, &block)
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

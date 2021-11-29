# Custom SAML Starategy declinata in CSI Piemonte per prelevare dall'header di risposta i campi
# (cfr. https://intranet.csi.it/web/wp-content/uploads/2021/01/Manuale-uso-integrazione-piattaforma-Shibboleth2.pdf):
# - 'Shib-Identita-Matricola', restituito solo per IAMIDPCSI e IAMIDPCRP
# - 'Shib-Identita-Nome', restituito sempre
# - 'Shib-Identita-Cognome', restituito sempre
class Csisaml < OmniAuth::Strategies::SAML
  # la custom strategy CSI deve chiamarsi 'saml' per funzionare
  # perche' si tratta di autenticazione SAML
  option :name, 'saml'

  # cfr. https://github.com/omniauth/omniauth-saml
  def initialize(app, *args, &block)
    config = Setting.get('auth_advanced_saml_credentials') || {}

    options = config.reject { |_k, v| v.blank? }
      .merge(
        attribute_statements: {
          nickname:   ['Shib-Identita-Matricola'],
          first_name: ['Shib-Identita-Nome'],
          last_name:  ['Shib-Identita-Cognome']
        }
      )
    args[0] = options

    super
  end
end

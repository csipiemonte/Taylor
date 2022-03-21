Setting.create_if_not_exists(
  title:       __('Authentication via %s'),
  name:        'auth_advanced_saml',
  area:        'Security::ThirdPartyAuthentication',
  description: __('Enables user authentication via %s.'),
  options:     {
    form: [
      {
        display: '',
        null:    true,
        name:    'auth_advanced_saml',
        tag:     'boolean',
        options: {
          true  => 'yes',
          false => 'no',
        },
      },
    ],
  },
  preferences: {
    controller:       'SettingsAreaSwitch',
    sub:              ['auth_advanced_saml_credentials'],
    title_i18n:       ['CSI-SAML'],
    description_i18n: ['CSI-SAML'],
    permission:       ['admin.security'],
  },
  state:       false,
  frontend:    true
)
Setting.create_if_not_exists(
  title:       __('SAML App Credentials'),
  name:        'auth_advanced_saml_credentials',
  area:        'Security::ThirdPartyAuthentication::SAML',
  description: __('Enables user authentication via SAML.'),
  options:     {
    form: [
      {
        display:     __('IDP SSO target URL'),
        null:        true,
        name:        'idp_sso_target_url',
        tag:         'input',
        placeholder: 'https://capriza.github.io/samling/samling.html',
      },
      {
        display:     __('IDP certificate'),
        null:        true,
        name:        'idp_cert',
        tag:         'input',
        placeholder: '-----BEGIN CERTIFICATE-----\n...-----END CERTIFICATE-----',
      },
      {
        display:     __('IDP certificate fingerprint'),
        null:        true,
        name:        'idp_cert_fingerprint',
        tag:         'input',
        placeholder: 'E7:91:B2:E1:...',
      },
      {
        display:     __('Name Identifier Format'),
        null:        true,
        name:        'name_identifier_format',
        tag:         'input',
        placeholder: 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
      },
      {
        display:     'Issuer',
        null:        true,
        name:        'issuer',
        tag:         'input',
        placeholder: 'YOUR_SERVICE_PROVIDER',
      },
      {
        display:     'Private Key',
        null:        true,
        name:        'private_key',
        tag:         'input',
        placeholder: '-----BEGIN RSA PRIVATE KEY-----\n...-----END RSA PRIVATE KEY-----',
      },
      {
        display:     'Assertion consumer service url',
        null:        true,
        name:        'assertion_consumer_service_url',
        tag:         'input',
        placeholder: 'http://zammad.example.com/auth/saml/callback',
      },
    ],
  },
  state:       {},
  preferences: {
    permission: ['admin.security'],
  },
  frontend:    false
)

old_saml_setting = Setting.find_by(name:'auth_saml')
old_saml_setting.preferences[:hidden] = true
old_saml_setting.save!


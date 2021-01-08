class SamlDatabase < OmniAuth::Strategies::SAML
  option :name, 'saml'

  def initialize(app, *args, &block)

    http_type = Setting.get('http_type')
    fqdn      = Setting.get('fqdn')

    # Use meta URL as entity id/issues as it is best practice.
    # See: https://community.zammad.org/t/saml-oidc-third-party-authentication/2533/13
    entity_id                      = "#{http_type}://#{fqdn}/auth/saml/metadata"
    assertion_consumer_service_url = "#{http_type}://#{fqdn}/auth/saml/callback"

    config  = Setting.get('auth_saml_credentials') || {}
    options = config.reject { |_k, v| v.blank? }
      .merge(
        assertion_consumer_service_url: "http://tst-covid-infra.ecosis.csi.it/auth/saml/callback",
        issuer:                         "SERVICE_PROVIDER_TST-COVID-INFRA.ECOSIS.CSI.IT_LIV1_ICSI",
        private_key: "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAwO7DwH6Ku5ePe1+pYGKCwgenbKvq2GOAUw8j5Eu4fYQg2zn3\n7vmSqrv/W7jOv02TDjqjI6j5B4i67MfTSuMqCTXv3aBtN01AZqjPbTM4b4+FAp5Q\nLj6CvFepxt4dTfW8xWnBGc4PsFJ5kacpmoSaGP803Dd6me4Y/rRt4sEMjdttsgbK\nYYYU7K8PEp9BSaLIJjngV/vGCfXH9g3HXJYc9WX//TTkPsWzfYIELfpm7EvTHqoq\nvfOo3TSS3KYiywvn5w65xC095CkhkEct5WhAoSsvpb7xKCvmrDkv/YWZy1kmMuJ9\nGxJeXhqkkEbAytvZZ3x7qVhnufDLKTxKEWn/WQIDAQABAoIBAHsQEYbYcI+l5hyw\n8S4MyBERpsaXhk4Occ0JLECz1/Mf84FCoZYqVVZYYlLUN/QofDOoTWUyo94dZfYg\no/LxoV+Mqvq4GNIckYaqCN1DvazTY+k+qDBHKUcPt7ik9xZCN+3IPibCnJlAklDI\nyq3IBS8KomIRdT94czMMTcdEkkhs4ijgPSYVXSKMcMfhP3XEqvhhUmZ/9GnRSqcJ\nPXIUITZsygh16RZSz8exxASouw7CWfuBFAgWECkH+r5u4f15hBe/GDxVFMuRD7HH\nLTsgN21mtYY3pLBnG1L5ILkpUGaUEELglhNKiZlVqxTN2zgjLhM3TgQ2rfh2eXYu\n1Kb/hL0CgYEA4WKGW2sJVIW0ndEcggo71T+sKrSzo1yprpUpPU5POLSzaPJHkeqT\n1/p9nYW7MTEbmr2eENfiAIiJe1qzIImCpK6xuwVZMjnYzyBsiJeOqZ2aolk2jLvs\nQpTHCqnY0PqY/qyh/456PB8CxKHK9XEqWrDn6UbihC8AW22q1YvbpT8CgYEA2yPB\ne2YM7sxFbzbz7ZTa6e2/Vua15uJLvCUw3YqzN3MRM9IaZyFr7iytoE/M0OWshRa2\n2KDl8wYtOKXhfd9DCR7bFmyWcaATS4349yST7SsNFtyqU2K9RQXP7hZB6vgsgCHk\nstpYskIinqdDJDP2DrvvvnMQfkapEXmJr1M1vWcCgYEAig6f3j+iZ3O/PyxoGf/K\nxsVJ4J7vqpGIHrifmj3tqP6HJzHBRVA7X4DAkUzpbSh3kEG2IPscJNd932Gfd77D\nl7yqgbS0/l8Qv09NLB4p9RvlLK0ZDPvPrLkVcyK2/MuEC/wS/0d2+HzGZUv11oKL\nPyI97FbPScjAn0B99HDHCmECgYBgTox/sM/KOtfhEqONLDgxSp0mkeoreBSUsTuS\ngZxVqCpNPe8Al/2ZBOWhaLC4tddl/h+JgNzOO06wcKZy7SXG4lqitkI/2XvhXpml\n89tXBe6Qt5XbY6+OoAlLt1hs7XiRL1QVDkSgwtP4KcYmKPfgbdPlPShodqFi3qkV\n9lnNzQKBgQCgArsWpY9FoE6w1benBwPcxLRO6Roqj9PAKCaLnFo1PK80ay19Mdw+\nzRdLth84L6HrnOWeK20WvtufwaSJWdlmxt3gZJoD4I0Yl82afb8Kml9Ggnp34v4c\nWde6Z9dAEMRpckXDuXLU+RyGK/QDr4mHe02ssOOj8z3hzfE9E8rxDg==\n-----END RSA PRIVATE KEY-----",
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

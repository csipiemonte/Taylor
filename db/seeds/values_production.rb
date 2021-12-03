remedy_env_vars = Setting.find_by(name: 'remedy_env_vars')
remedy_env_vars.state = {
  access_token:  ENV['ACCESS_TOKEN'],
  base_url:      'https://tst-api-piemonte.ecosis.csi.it/tecno/troubleticketing/v1',
  request_id:    'zammad_to_remedy',
  forwarded_for: '127.0.0.1'
}
remedy_env_vars.save!

classification_engine_api_url = Setting.find_by(name: 'classification_engine_api_settings')
# TODO, impostata provvisoriamente la URL di test, da cambiare con quella di produzione, quando disponibile
classification_engine_api_url.state = 'http://ts-ap1-be-bot-nextcrm.site02.nivolapiemonte.it/mlflow/mailclasstributi'
classification_engine_api_url.save!

chat_bot_api_url = Setting.find_by(name: 'chat_bot_api_settings')
# TODO, impostata provvisoriamente la URL di test, da cambiare con quella di produzione, quando disponibile
chat_bot_api_url.state = 'http://ts-ap1-be-bot-nextcrm.site02.nivolapiemonte.it/botplat/example'
chat_bot_api_url.save!

saml_settings = Setting.find_by(name: 'auth_advanced_saml_credentials')
saml_settings.state = {
  idp_sso_target_url:             'https://intranet.csi.it/iamidpcsi/profile/SAML2/Redirect/SSO',
  idp_cert:                       '-----BEGIN CERTIFICATE----- MIIEtDCCA5ygAwIBAgIDAO94MA0GCSqGSIb3DQEBBQUAMIGqMQswCQYDVQQGEwJJ VDELMAkGA1UECBMCVE8xETAPBgNVBAcTCFBpZW1vbnRlMRkwFwYDVQQKExBTaXN0 ZW1hIFBpZW1vbnRlMSQwIgYDVQQLExtDZW50cm8gVGVjbmljbyBDU0kgUGllbW9u dGUxHDAaBgNVBAMTE1Npc3RlbWEgUGllbW9udGUgQ0ExHDAaBgkqhkiG9w0BCQEW DWNhLWdycEBjc2kuaXQwHhcNMTEwNDE5MTQ0NTIyWhcNMTUwMTI4MTQxOTMyWjCB rDELMAkGA1UEBhMCSVQxCzAJBgNVBAgTAlRPMREwDwYDVQQHEwhQaWVtb250ZTEZ MBcGA1UEChMQU2lzdGVtYSBQaWVtb250ZTEkMCIGA1UECxMbQ2VudHJvIFRlY25p Y28gQ1NJIFBpZW1vbnRlMRgwFgYDVQQDEw9pbnRyYW5ldC5jc2kuaXQxIjAgBgkq hkiG9w0BCQEWE2dlc3Rpb25lLndlYkBjc2kuaXQwgZ8wDQYJKoZIhvcNAQEBBQAD gY0AMIGJAoGBAOuhEPM47u8O7o8U/p9ybRbV3MNWf9hdIC1wlwpGuZKU7seh8i2h aT3iX2GpIureGCzQ+vCbCj7p9SRW8NxE+KpmFYaGq8Zz9rBgNFdPWtD2bnWZY1xr Fg2mV0tHUlicuxupboQGYVStJY0OGndeb53lNfeljeETQxy8qTIRnezdAgMBAAGj ggFhMIIBXTAJBgNVHRMEAjAAMBEGCWCGSAGG+EIBAQQEAwIFYDBABglghkgBhvhC AQ0EMxYxQ2VydGlmaWNhdG8gZGkgYXV0ZW50aWNhemlvbmUgZGlnaXRhbGUgcGVy IHNlcnZlcjAdBgNVHQ4EFgQUDb1Pgb1tHDrPKPRonfRrz0xKslAwHwYDVR0jBBgw FoAUKMk/24eqvP5+yEpqqAj6Wn0YiRUwLwYIKwYBBQUHAQEEIzAhMB8GCCsGAQUF BzABhhNodHRwOi8vb2NzcC5jc2kuaXQvMEwGA1UdHwRFMEMwJKAioCCGHmh0dHA6 Ly9jYS5jc2kuaXQvQ1JML2NhY3JsLmNybDAboBmgF4YVbGRhcDovL2NhbGRhcC5j c2kuaXQvMDwGA1UdIAQ1MDMwMQYKKwYBBAH4EgEBATAjMCEGCCsGAQUFBwIBFhVo dHRwOi8vY2EuY3NpLml0L0NQUy8wDQYJKoZIhvcNAQEFBQADggEBAGd1e/QAoXP7 HB7TkKdLs2jJd9zwqwxo3gIYq8aGzQjIaC8iqQxfzd3/NuIJOwv1Ov0BrqTQEFYO +8+yM8+9zDFj6hhTKGpCIVyxmb2CMqzoiyzabN437jNVkH0/TOMr4v83Yo2pDLb9 4/QHI41cbbGjnh0l+4XGa75W4wYe4xYnfgme0Kvyq9tWCjVRcdpgYLVl7SHV3mb1 u4q/yT3Re6estD9MMrrDEmlNxOMnJoH3ahtaQ6Xai98gsc6OfFykOvbSSWBujLC4 CVz1lpazRDXw2/1cBjklZIe+7NcXMUGP91nouQAw6Tsa8wP7r7/yhmOzBqbQCGDx jOTz4haj/Mg= -----END CERTIFICATE-----',
  idp_cert_fingerprint:           '',
  name_identifier_format:         '',
  issuer:                         'SERVICE_PROVIDER_NEXTCRM-BO.NIVOLAPIEMONTE.IT_LIV1_ICSI',
  private_key:                    '-----BEGIN RSA PRIVATE KEY----- MIIEpAIBAAKCAQEAwO7DwH6Ku5ePe1+pYGKCwgenbKvq2GOAUw8j5Eu4fYQg2zn3 7vmSqrv/W7jOv02TDjqjI6j5B4i67MfTSuMqCTXv3aBtN01AZqjPbTM4b4+FAp5Q Lj6CvFepxt4dTfW8xWnBGc4PsFJ5kacpmoSaGP803Dd6me4Y/rRt4sEMjdttsgbK YYYU7K8PEp9BSaLIJjngV/vGCfXH9g3HXJYc9WX//TTkPsWzfYIELfpm7EvTHqoq vfOo3TSS3KYiywvn5w65xC095CkhkEct5WhAoSsvpb7xKCvmrDkv/YWZy1kmMuJ9 GxJeXhqkkEbAytvZZ3x7qVhnufDLKTxKEWn/WQIDAQABAoIBAHsQEYbYcI+l5hyw 8S4MyBERpsaXhk4Occ0JLECz1/Mf84FCoZYqVVZYYlLUN/QofDOoTWUyo94dZfYg o/LxoV+Mqvq4GNIckYaqCN1DvazTY+k+qDBHKUcPt7ik9xZCN+3IPibCnJlAklDI yq3IBS8KomIRdT94czMMTcdEkkhs4ijgPSYVXSKMcMfhP3XEqvhhUmZ/9GnRSqcJ PXIUITZsygh16RZSz8exxASouw7CWfuBFAgWECkH+r5u4f15hBe/GDxVFMuRD7HH LTsgN21mtYY3pLBnG1L5ILkpUGaUEELglhNKiZlVqxTN2zgjLhM3TgQ2rfh2eXYu 1Kb/hL0CgYEA4WKGW2sJVIW0ndEcggo71T+sKrSzo1yprpUpPU5POLSzaPJHkeqT 1/p9nYW7MTEbmr2eENfiAIiJe1qzIImCpK6xuwVZMjnYzyBsiJeOqZ2aolk2jLvs QpTHCqnY0PqY/qyh/456PB8CxKHK9XEqWrDn6UbihC8AW22q1YvbpT8CgYEA2yPB e2YM7sxFbzbz7ZTa6e2/Vua15uJLvCUw3YqzN3MRM9IaZyFr7iytoE/M0OWshRa2 2KDl8wYtOKXhfd9DCR7bFmyWcaATS4349yST7SsNFtyqU2K9RQXP7hZB6vgsgCHk stpYskIinqdDJDP2DrvvvnMQfkapEXmJr1M1vWcCgYEAig6f3j+iZ3O/PyxoGf/K xsVJ4J7vqpGIHrifmj3tqP6HJzHBRVA7X4DAkUzpbSh3kEG2IPscJNd932Gfd77D l7yqgbS0/l8Qv09NLB4p9RvlLK0ZDPvPrLkVcyK2/MuEC/wS/0d2+HzGZUv11oKL PyI97FbPScjAn0B99HDHCmECgYBgTox/sM/KOtfhEqONLDgxSp0mkeoreBSUsTuS gZxVqCpNPe8Al/2ZBOWhaLC4tddl/h+JgNzOO06wcKZy7SXG4lqitkI/2XvhXpml 89tXBe6Qt5XbY6+OoAlLt1hs7XiRL1QVDkSgwtP4KcYmKPfgbdPlPShodqFi3qkV 9lnNzQKBgQCgArsWpY9FoE6w1benBwPcxLRO6Roqj9PAKCaLnFo1PK80ay19Mdw+ zRdLth84L6HrnOWeK20WvtufwaSJWdlmxt3gZJoD4I0Yl82afb8Kml9Ggnp34v4c Wde6Z9dAEMRpckXDuXLU+RyGK/QDr4mHe02ssOOj8z3hzfE9E8rxDg== -----END RSA PRIVATE KEY-----',
  assertion_consumer_service_url: ENV['ASSERTION_CONSUMER_SERVICE_URL']
}
saml_settings.save!

remedy_base_url = Setting.find_by(name: 'remedy_base_url')
remedy_base_url.state = 'https://api-piemonte.csi.it/tecno/troubleticketin/v1'
remedy_base_url.save!

remedy_token = Setting.find_by(name: 'remedy_token')
remedy_token.state = '71087ed6-07a0-3628-a0c5-5601aae89ae8'
remedy_token.save!

notification_sender_email = Setting.find_by(name: 'notification_sender')
notification_sender_email.state = 'No-reply CSI Assistenza <admin.assistenza.nextcrm@csi.it>'
notification_sender_email.save!

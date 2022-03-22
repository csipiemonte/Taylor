# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

product_line = ENV['PRODUCT_LINE']
raise 'variabile ambiente PRODUCT_LINE non trovata' if !product_line

environment = Rails.env.downcase

seed_config_file = Rails.root.join('config', 'seeds', "#{product_line}.yml")
seed_config = HashWithIndifferentAccess.new(YAML.safe_load(File.read(File.expand_path(seed_config_file, __FILE__))))

raise "environment '#{environment}' non trovato nel file di configurazione '#{seed_config_file}' " if !seed_config[environment]

seeds = seed_config[environment][:seeds]

remedy_env_vars = Setting.find_by(name: 'remedy_env_vars')
remedy_env_vars.state = {
  access_token:  ENV['ACCESS_TOKEN'],
  base_url:      seeds[:remedy][:base_url],
  request_id:    seeds[:remedy][:request_id],
  forwarded_for: seeds[:remedy][:forwarded_for]
}
remedy_env_vars.save!

classification_engine_api_url = Setting.find_by(name: 'classification_engine_api_settings')
classification_engine_api_url.state = seeds[:classification_engine][:api_url]
classification_engine_api_url.save!

chat_bot_api_url = Setting.find_by(name: 'chat_bot_api_settings')
# Attenzione per sviluppi su virtual machine Virtual Box, impostare
# chat_bot_api_url.state = 'https://tst-unlockpa.csi.it/botplat'
# e come location (argomento della chat) 'bolloauto'
chat_bot_api_url.state = seeds[:chat_bot][:api_url]
chat_bot_api_url.save!

saml_settings = Setting.find_by(name: 'auth_advanced_saml_credentials')
saml_settings.state = {
  idp_sso_target_url:             seeds[:auth_advanced_saml][:idp_sso_target_url],
  idp_cert:                       seeds[:auth_advanced_saml][:idp_cert],
  idp_cert_fingerprint:           '',
  name_identifier_format:         '',
  issuer:                         seeds[:auth_advanced_saml][:issuer],
  private_key:                    seeds[:auth_advanced_saml][:private_key],
  assertion_consumer_service_url: ENV['ASSERTION_CONSUMER_SERVICE_URL']
}
saml_settings.save!

remedy_base_url = Setting.find_by(name: 'remedy_base_url')
remedy_base_url.state = seeds[:remedy][:base_url]
remedy_base_url.save!

remedy_token = Setting.find_by(name: 'remedy_token')
remedy_token.state = seeds[:remedy][:token]
remedy_token.save!

notification_sender_email = Setting.find_by(name: 'notification_sender')
notification_sender_email.state = seeds[:notification][:sender_email]
notification_sender_email.save!

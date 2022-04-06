# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/chat_monitor',                                  to: 'chats_monitor#index',  via: :get
  match api_path + '/chat_monitor/messages/:chat_session_id',        to: 'chats_monitor#show',   via: :get
end

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

    match api_path + '/chat_monitor',                                  to: 'chat_monitor#index',   via: :get
    match api_path + '/chat_monitor/messages/:chat_session_id',                to: 'chat_monitor#show',   via: :get

end

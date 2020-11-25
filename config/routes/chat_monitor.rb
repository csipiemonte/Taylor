Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

    match api_path + '/chat_monitor',                to: 'chat_monitor#index',   via: :get

end

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/chat_sessions',                to: 'chat_sessions#index',   via: :get
  match api_path + '/chat_sessions/:id',            to: 'chat_sessions#show',    via: :get

end

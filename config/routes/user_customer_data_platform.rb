Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/users/:id/cdp_events',   to: 'user_cdp_events#index',   via: :get
end

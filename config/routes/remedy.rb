Zammad::Application.routes.draw do
    api_path = Rails.configuration.api_path

  match api_path + '/remedy_tickets',                                       to: 'remedy#index',             via: :get
  match api_path + '/sync_remedy_tickets',                                  to: 'remedy#sync',             via: :get
end

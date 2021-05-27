Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/virtual_agents',           to: 'virtual_agent#index',      via: :get

end

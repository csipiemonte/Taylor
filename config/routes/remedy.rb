Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # Index Remedy Tickets
  match api_path + '/remedy_tickets',                                to: 'remedy#index',                    via: :get
  match api_path + '/remedy_migrating',                              to: 'remedy#migrating',                via: :get

  # Objects Mappings
  match api_path + '/remedy_states',                                 to: 'remedy#states',                   via: :get
  match api_path + '/remedy_priorities',                             to: 'remedy#priorities',               via: :get

  # Integration Settings
  match api_path + '/most_recent_state',                             to: 'remedy#most_recent_state',        via: :post
end

Zammad::Application.routes.draw do
    api_path = Rails.configuration.api_path


  match api_path + '/remedy_migrating',                              to: 'remedy#migrating',        via: :get
  match api_path + '/remedy_tickets',                                to: 'remedy#index',            via: :get
  match api_path + '/remedy_keys',                                   to: 'remedy#keys',             via: :get
  match api_path + '/remedy_states',                                 to: 'remedy#states',           via: :get
  match api_path + '/create_remedy_tickets',                         to: 'remedy#create',           via: :post
  match api_path + '/remedy_triple',                                 to: 'remedy#triple',           via: :post
  match api_path + '/ticket_categorization',                         to: 'remedy#categorization',   via: :post
  match api_path + '/remedy_triples_table',                          to: 'remedy#triples_table',    via: :get
  match api_path + '/remedy_tickets',                                to: 'remedy#index',            via: :get
  match api_path + '/sync_remedy_tickets',                           to: 'remedy#sync',             via: :get
  match api_path + '/remedy_priorities',                               to: 'remedy#priorities',       via: :get

end

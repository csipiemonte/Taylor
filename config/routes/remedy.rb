Zammad::Application.routes.draw do
    api_path = Rails.configuration.api_path


  # Create a new Remedy Ticket
  match api_path + '/create_remedy_tickets',                         to: 'remedy#create',                   via: :post

  # Indexing Remedy Tickets
  match api_path + '/remedy_tickets',                                to: 'remedy#index',                    via: :get
  match api_path + '/remedy_migrating',                              to: 'remedy#migrating',                via: :get

  # Objects Mappings
  match api_path + '/remedy_states',                                 to: 'remedy#states',                   via: :get
  match api_path + '/remedy_triple',                                 to: 'remedy#triple',                   via: :post
  match api_path + '/ticket_categorization',                         to: 'remedy#categorization',           via: :post
  match api_path + '/remedy_triples_table',                          to: 'remedy#triples_table',            via: :get
  match api_path + '/remedy_priorities',                             to: 'remedy#priorities',               via: :get

  # Integration Settings
  match api_path + '/remedy_settings',                               to: 'remedy#settings',                 via: :get

  match api_path + '/sync_remedy_tickets',                           to: 'remedy#sync',                     via: :get

end

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # remedy_tickets
  match api_path + '/tickets/search',                                to: 'remedy_tickets#search',            via: %i[get post]
  match api_path + '/tickets/selector',                              to: 'remedy_tickets#selector',          via: :post
  match api_path + '/tickets',                                       to: 'remedy_tickets#index',             via: :get
  match api_path + '/tickets/:id',                                   to: 'remedy_tickets#show',              via: :get
  match api_path + '/tickets',                                       to: 'remedy_tickets#create',            via: :post
  match api_path + '/tickets/:id',                                   to: 'remedy_tickets#update',            via: :put
  match api_path + '/tickets/:id',                                   to: 'remedy_tickets#destroy',           via: :delete
  match api_path + '/ticket_create',                                 to: 'remedy_tickets#remedy_ticket_create',     via: :get
  match api_path + '/ticket_split',                                  to: 'remedy_tickets#remedy_ticket_split',      via: :get
  match api_path + '/ticket_history/:id',                            to: 'remedy_tickets#remedy_ticket_history',    via: :get
  match api_path + '/ticket_customer',                               to: 'remedy_tickets#remedy_ticket_customer',   via: :get
  match api_path + '/ticket_related/:remedy_ticket_id',              to: 'remedy_tickets#remedy_ticket_related',    via: :get
  match api_path + '/ticket_recent',                                 to: 'remedy_tickets#remedy_ticket_recent',     via: :get
  match api_path + '/ticket_merge/:slave_remedy_ticket_id/:master_remedy_ticket_number', to: 'remedy_tickets#remedy_ticket_merge', via: :get
  match api_path + '/ticket_stats',                                  to: 'remedy_tickets#stats',             via: :get

  # remedy_ticket overviews
  match api_path + '/ticket_overviews',                              to: 'remedy_ticket_overviews#show',     via: :get

  # remedy_ticket priority
  match api_path + '/ticket_priorities',                             to: 'remedy_ticket_priorities#index',   via: :get
  match api_path + '/ticket_priorities/:id',                         to: 'remedy_ticket_priorities#show',    via: :get
  match api_path + '/ticket_priorities',                             to: 'remedy_ticket_priorities#create',  via: :post
  match api_path + '/ticket_priorities/:id',                         to: 'remedy_ticket_priorities#update',  via: :put
  match api_path + '/ticket_priorities/:id',                         to: 'remedy_ticket_priorities#destroy', via: :delete

  # remedy_ticket state
  match api_path + '/ticket_states',                                 to: 'remedy_ticket_states#index',       via: :get
  match api_path + '/ticket_states/:id',                             to: 'remedy_ticket_states#show',        via: :get
  match api_path + '/ticket_states',                                 to: 'remedy_ticket_states#create',      via: :post
  match api_path + '/ticket_states/:id',                             to: 'remedy_ticket_states#update',      via: :put
  match api_path + '/ticket_states/:id',                             to: 'remedy_ticket_states#destroy',     via: :delete

  # remedy_ticket articles
  match api_path + '/ticket_articles',                               to: 'remedy_ticket_articles#index',           via: :get
  match api_path + '/ticket_articles/:id',                           to: 'remedy_ticket_articles#show',            via: :get
  match api_path + '/ticket_articles/by_remedy_ticket/:id',          to: 'remedy_ticket_articles#index_by_remedy_ticket', via: :get
  match api_path + '/ticket_articles',                               to: 'remedy_ticket_articles#create',          via: :post
  match api_path + '/ticket_articles/:id',                           to: 'remedy_ticket_articles#update',          via: :put
  match api_path + '/ticket_articles/:id',                           to: 'remedy_ticket_articles#destroy',     via: :delete
  match api_path + '/ticket_attachment/:remedy_ticket_id/:article_id/:id',  to: 'remedy_ticket_articles#attachment',      via: :get
  match api_path + '/ticket_attachment_upload_clone_by_article/:article_id', to: 'remedy_ticket_articles#remedy_ticket_attachment_upload_clone_by_article', via: :post
  match api_path + '/ticket_article_plain/:id',                      to: 'remedy_ticket_articles#article_plain',   via: :get
  match api_path + '/ticket_articles/:id/retry_security_process',    to: 'remedy_ticket_articles#retry_security_process', via: :post
end

Zammad::Application.routes.draw do
    api_path = Rails.configuration.api_path

  # Index Remedy Tickets
  match api_path + '/public/tickets',                                to: 'external_tickets#index',    via: :get
  match api_path + '/public/tickets/:id',                            to: 'external_tickets#show',     via: :get

end

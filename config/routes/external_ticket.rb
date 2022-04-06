Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  # Estese le API native Zammad con:
  # - dati delle external activities, se le permission lo consentono
  # - mascherati gli stati interni dei ticket (trasformati in stati visibili esternamente)
  match api_path + '/public/tickets',     to: 'external_tickets#index', via: :get
  match api_path + '/public/tickets/:id', to: 'external_tickets#show',  via: :get
end

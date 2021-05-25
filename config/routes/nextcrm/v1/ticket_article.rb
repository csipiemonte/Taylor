Zammad::Application.routes.draw do

  scope module: 'api/nextcrm/v1', path: 'api/nextcrm/v1' do

    match  '/tickets/:id/articles',                   to: 'ticket_articles#index_by_ticket',              via: :get
    match  '/tickets/:ticket_id/articles',            to: 'ticket_articles#create',                       via: :post
    # match  '/tickets/:ticket_id/articles/:id',        to: 'ticket_articles#update',                       via: :put
    # match  '/tickets/:ticket_id/articles/:id',        to: 'ticket_articles#destroy',                      via: :delete
  end
  
 end

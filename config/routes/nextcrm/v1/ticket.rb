Zammad::Application.routes.draw do

  scope module: 'api/nextcrm/v1', path: 'api/nextcrm/v1' do
    match  '/tickets',                                       to: 'tickets#index',                         via: :get
    match  '/tickets/search',                                to: 'tickets#search',                         via: :get
    match  '/tickets',                                       to: 'tickets#create',                        via: :post
    match  '/tickets/:id',                                   to: 'tickets#show',                          via: :get
    match  '/tickets/:id',                                   to: 'tickets#update',                        via: :put
   
  end
  
 end

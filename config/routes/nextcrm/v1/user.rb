Zammad::Application.routes.draw do

  scope module: 'api/nextcrm/v1', path: 'api/nextcrm/v1' do
    match  '/users',                                       to: 'users#index',              via: :get
    match  '/users/search',                                to: 'users#search',             via: :get
    match  '/users',                                       to: 'users#create',             via: :post
  end
 
 end

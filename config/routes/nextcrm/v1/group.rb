Zammad::Application.routes.draw do

  scope module: 'api/nextcrm/v1', path: 'api/nextcrm/v1' do
    match  '/groups',                                       to: 'groups#index',              via: :get
  end
 
 end

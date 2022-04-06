Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

    match api_path + '/service_catalog',                              to: 'categories#index_service_catalog',   via: :get
    match api_path + '/service_catalog/:id',                          to: 'categories#show_service_catalog',    via: :get

    match api_path + '/service_catalog_sub_item/',                    to: 'categories#index_service_catalog_sub_item',   via: :get
    match api_path + '/service_catalog_sub_item/:id',                 to: 'categories#show_service_catalog_sub_item',    via: :get

    match api_path + '/asset',                                        to: 'categories#index_asset',   via: :get
    match api_path + '/asset/:id',                                    to: 'categories#show_asset',    via: :get
end

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

    match api_path + '/external_activity/system/:ticketing_system_id',      to: 'external_activity#index_external_activity',           via: :get
    match api_path + '/external_activity/id/:id',                           to: 'external_activity#show_external_activity',            via: :get
    match api_path + '/external_activity',                                  to: 'external_activity#create_external_activity',          via: :post

    match api_path + '/external_ticketing_system/',                         to: 'external_activity#index_external_ticketing_system',   via: :get
    match api_path + '/external_ticketing_system/:id',                      to: 'external_activity#show_external_ticketing_system',    via: :get

end

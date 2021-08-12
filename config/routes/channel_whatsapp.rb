Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/channels_whatsapp',                         to: 'channels_whatsapp#index',    via: :get
  match api_path + '/channels_whatsapp',                         to: 'channels_whatsapp#add',      via: :post
  match api_path + '/channels_whatsapp/:id',                     to: 'channels_whatsapp#update',   via: :put
  match api_path + '/channels_whatsapp_webhook/callback',        to: 'channels_whatsapp#webhook',  via: :post
  match api_path + '/channels_whatsapp_disable',                 to: 'channels_whatsapp#disable',  via: :post
  match api_path + '/channels_whatsapp_enable',                  to: 'channels_whatsapp#enable',   via: :post
  match api_path + '/channels_whatsapp',                         to: 'channels_whatsapp#destroy',  via: :delete

end

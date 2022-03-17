# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

Zammad::Application.routes.draw do
  api_path = Rails.configuration.api_path

  match api_path + '/karma',   to: 'karma#index', via: :get

end

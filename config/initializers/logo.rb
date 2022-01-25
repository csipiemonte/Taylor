# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

Rails.application.reloader.to_prepare do
  # issue 454, vedere issue zammad 3933
  #next if !ActiveRecord::Base.connected?
  # sync logo to fs / only if settings already exists
  next if ActiveRecord::Base.connection.tables.exclude?('settings')
  next if Setting.column_names.exclude?('state_current')

  StaticAssets.sync
end

# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[password bind_pw state.body state.article.body article.attachments.data attachments.data]

# external activity parameters
Rails.application.config.filter_parameters += %i[file]

# proc filter per body
Rails.application.config.filter_parameters << lambda do |param_name, value|
  if %w[body article.body].include?(param_name)
    value.slice!(500...)
  end
end
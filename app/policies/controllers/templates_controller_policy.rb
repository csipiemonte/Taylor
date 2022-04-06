# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class Controllers::TemplatesControllerPolicy < Controllers::ApplicationControllerPolicy
  # CSI custom - aggiunta permessi templates
  permit! %i[create update destroy], to: 'admin.template'

  default_permit!(['ticket.agent', 'admin.template'])
end

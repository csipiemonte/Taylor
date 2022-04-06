class Controllers::ExternalActivityControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['ticket.agent', 'admin']) # si forniscono le permissions
end

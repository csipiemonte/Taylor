class Controllers::ExternalActivityControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['ticket.agent', 'admin', 'virtual_agent.aligner']) # si forniscono le permissions
end

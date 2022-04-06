class Controllers::ExternalTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['ticket.agent', 'virtual_agent.api_user', 'ticket.customer']) # si forniscono le permissions
end

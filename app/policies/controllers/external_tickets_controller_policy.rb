class Controllers::ExternalTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['agent', 'virtual_agent.api_user', 'ticket.customer']) # si forniscono le permissions
end

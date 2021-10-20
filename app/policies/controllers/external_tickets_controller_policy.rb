class Controllers::ExternalTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['agent', 'virtual_agent', 'ticket.customer']) # si forniscono le permissions
end

class Controllers::VirtualAgentTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['agent', 'virtual_agent', 'ticket.customer'])
end

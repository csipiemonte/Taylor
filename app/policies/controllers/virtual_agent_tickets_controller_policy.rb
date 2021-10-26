class Controllers::VirtualAgentTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['agent', 'virtual_agent.api_user', 'ticket.customer'])
end

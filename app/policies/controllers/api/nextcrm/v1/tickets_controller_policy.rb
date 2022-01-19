class Controllers::Api::Nextcrm::V1::TicketsControllerPolicy < Controllers::TicketsControllerPolicy
  default_permit!(['ticket.agent', 'virtual_agent.api_user'])
  permit! %i[create ticket_customer ticket_history ticket_related ticket_recent ticket_merge ticket_split], to: ['ticket.agent', 'virtual_agent.api_user']
end

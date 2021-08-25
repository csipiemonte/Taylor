class Controllers::Api::Nextcrm::V1::TicketsControllerPolicy < Controllers::TicketsControllerPolicy
    default_permit!(['agent', 'virtual_agent'])
end
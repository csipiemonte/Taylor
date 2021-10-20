class Controllers::ExternalTicketsControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['agent', 'virtual_agent', 'customer'])
end

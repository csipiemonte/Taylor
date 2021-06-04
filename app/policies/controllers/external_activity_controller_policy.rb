class Controllers::ExternalActivityControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['ticket.agent','admin'])
end

class Controllers::UserCdpEventsControllerPolicy < Controllers::ApplicationControllerPolicy
  # permit! %i[import_example import_start], to: 'admin.user'
  # permit! %i[search history create update], to: ['ticket.agent', 'admin.user']
  default_permit!(['ticket.agent', 'admin.user'])
end

#The "Virtual Agent" is a custom role that inherits all permissions from the ordinary "Agent" role plus an extra dedicated permission
virtual_agent = Role.create_if_not_exists(
  id:                5,
  name:              'Virtual Agent',
  note:              'To work on Tickets.',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
)

Permission.create_if_not_exists(
  name:        'virtual_agent',
  note:        'Virtual Agent Interface',
  preferences: {},
)

# Virtual agent specific permission
virtual_agent.permission_grant('virtual_agent')

# Base agent default permission
virtual_agent.permission_grant('user_preferences')
virtual_agent.permission_grant('ticket.agent')
virtual_agent.permission_grant('chat.agent')
virtual_agent.permission_grant('cti.agent')
virtual_agent.permission_grant('knowledge_base.reader')






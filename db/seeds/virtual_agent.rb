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

############
# TRANSLATIONS


api_management = Role.create_if_not_exists(
  id:                6,
  name:              'Api Management',
  note:              'Login Account for external Api Manager',
  preferences:       {
    not: ['Customer','Agent', 'Admin'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
)

Permission.create_if_not_exists(
  name:        'api_manager',
  note:        'Access to NextCRM API by external Api Manager',
  preferences: {},
)

# Api manger specific permission
api_manager_permission = Permission.lookup(name: 'api_manager')
api_management.permission_ids = [api_manager_permission.id]

Translation.create_if_not_exists(
  locale:         "it-it",
  source:         "Access to NextCRM API by external Api Manager",
  target:         "Accesso alle API NEXTCRM via Api Manager",
  target_initial: "Accesso alle API NEXTCRM via Api Manager",
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)
Translation.create_if_not_exists(
  locale:         "it-it",
  source:         "Login Account for external Api Manager",
  target:         "Login Account per Api Manager",
  target_initial: "Login Account per Api Manager",
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)
Translation.create_if_not_exists(
  locale:         "it-it",
  source:         "Virtual Agent",
  target:         "Operatore Virtuale",
  target_initial: "Operatore Virtuale",
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)






def assign_permissions_to_virtual_agent (virtual_agent, permission_name)
  agent = Role.find_by(name:"Agent")
  virtual_agent.permissions = agent.permissions
  virtual_agent.permission_grant('virtual_agent')
  virtual_agent.permission_grant(permission_name)
end

# Virtual Agents inherits all permissions from the ordinary Agent role. They also have their own specifici permissions
Permission.create_if_not_exists(
  name:        'virtual_agent',
  note:        'Virtual Agent Interface',
  preferences: {},
)
Permission.create_if_not_exists(
  name:        'virtual_agent.chatbot',
  note:        'Handle chats automatically',
  preferences: {},
)
Permission.create_if_not_exists(
  name:        'virtual_agent.api_user',
  note:        'Use API as an agent',
  preferences: {},
)
Permission.create_if_not_exists(
  name:        'virtual_agent.rpa',
  note:        'Simulate agents behaviour',
  preferences: {},
)

virtual_agent_chatbot = Role.create_if_not_exists(
  id:                5,
  name:              'Virtual Agent (Chatbot)',
  note:              'To automatically handle incoming chat',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name:'Virtual Agent (Chatbot)')

virtual_agent_api_user = Role.create_if_not_exists(
  id:                7,
  name:              'Virtual Agent (Api User)',
  note:              'To perform api calls as an agent',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name:'Virtual Agent (Api User)')

virtual_agent_rpa = Role.create_if_not_exists(
  id:                8,
  name:              'Virtual Agent (RPA)',
  note:              'To simulate agent behaviour on UI',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name:'Virtual Agent (RPA)')


assign_permissions_to_virtual_agent virtual_agent_chatbot, 'virtual_agent.chatbot'
assign_permissions_to_virtual_agent virtual_agent_api_user, 'virtual_agent.api_user'
assign_permissions_to_virtual_agent virtual_agent_rpa, 'virtual_agent.rpa'


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


#creating translations
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
Translation.create_if_not_exists(
  locale:         "it-it",
  source:         "Virtual Agent %s",
  target:         "Operatore Virtuale %s",
  target_initial: "Operatore Virtuale %s",
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)





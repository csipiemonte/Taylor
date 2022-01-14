# Copyright (C) 2021 CSI Piemonte, https://www.csipiemonte.it/
#
# Permissions create per i role di tipo Virtual Agent

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

# Creazione roles di tipo 'virtual_agent*'
virtual_agent_chatbot = Role.create_if_not_exists(
  name:              'Virtual Agent (Chatbot)',
  note:              'To automatically handle incoming chat',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name: 'Virtual Agent (Chatbot)')

virtual_agent_chatbot.permission_grant('virtual_agent.chatbot')

virtual_agent_api_user = Role.create_if_not_exists(
  name:              'Virtual Agent (Api User)',
  note:              'To perform API calls as an agent',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name: 'Virtual Agent (Api User)')

virtual_agent_api_user.permission_grant('virtual_agent.api_user')

virtual_agent_rpa = Role.create_if_not_exists(
  name:              'Virtual Agent (RPA)',
  note:              'To simulate agent behaviour on UI',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name: 'Virtual Agent (RPA)')

virtual_agent_rpa.permission_grant('virtual_agent.rpa')

# Il role 'Virtual Agent (Aligner)' deve poter operare su external activities (in lettura ed in scrittura)
# e sui ticket (in sola lettura).
virtual_agent_aligner = Role.create_if_not_exists(
  name:              'Virtual Agent (Aligner)',
  note:              'To perform alignement from external tickenting systems to Zammand external activities',
  preferences:       {
    not: ['Customer'],
  },
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
) || Role.find_by(name: 'Virtual Agent (Aligner)')

virtual_agent_aligner.permission_grant('ticket.agent')
<<<<<<< HEAD

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         'Virtual Agent %s',
  target:         'Operatore Virtuale %s',
  target_initial: 'Operatore Virtuale %s',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

# Utente impiegato per eseguire le operazioni di allineamento fra i ticket
# presenti sugli external ticketing system e le Zammad external activities.
# Deve avere come role 'Virtual Agent (Aligner)' e poi
# deve avere il controllo pieno sui gruppi (abilitazioni date dalla pagina di dettaglio utente)
User.create_if_not_exists(
  login:     'aligner.agent@csi.it',
  firstname: 'Aligner',
  lastname:  'Agent',
  email:     'aligner.agent@csi.it',
  password:  'AliP21_ext!',
  active:    true,
  roles:     [ Role.find_by(name: 'Virtual Agent (Aligner)') ]
)

=======

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         'Virtual Agent %s',
  target:         'Operatore Virtuale %s',
  target_initial: 'Operatore Virtuale %s',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

# Utente impiegato per eseguire le operazioni di allineamento fra i ticket
# presenti sugli external ticketing system e le Zammad external activities.
# Deve avere come role 'Virtual Agent (Aligner)' e poi
# deve avere il controllo pieno sui gruppi (abilitazioni date dalla pagina di dettaglio utente)
User.create_if_not_exists(
  login:     'aligner.agent@csi.it',
  firstname: 'Aligner',
  lastname:  'Agent',
  email:     'aligner.agent@csi.it',
  password:  'AliP21_ext!',
  active:    true,
  roles:     [ Role.find_by(name: 'Virtual Agent (Aligner)') ]
)

>>>>>>> feature/webchat
# Api Management
api_management = Role.create_if_not_exists(
  name:              'Api Management',
  note:              'Login Account for external Api Manager',
  preferences:       {
    not: ['Customer', 'Agent', 'Admin'],
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
  locale:         'it-it',
  source:         'Access to NextCRM API by external Api Manager',
  target:         'Accesso alle API NEXTCRM via Api Manager',
  target_initial: 'Accesso alle API NEXTCRM via Api Manager',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         'Login Account for external Api Manager',
  target:         'Login Account per Api Manager',
  target_initial: 'Login Account per Api Manager',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

# No preferences, role utilizzato da chi proviene la prima volta
# dall'autenticazione SAML
Role.create_if_not_exists(
  name:              'No preferences',
  note:              'Ruolo di atterraggio delle login SAML via IAMIDPCSI/IAMIDP',
  preferences:       {},
  default_at_signup: false,
  updated_by_id:     1,
  created_by_id:     1
)

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         'No preferences',
  target:         'Nessuna abilitazione',
  target_initial: 'Nessuna abilitazione',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

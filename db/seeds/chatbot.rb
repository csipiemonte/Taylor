Setting.create_if_not_exists(
  title:       'Defines transaction backend.',
  name:        'Chatbot_transaction',
  area:        'Transaction::Backend::Async',
  description: 'Defines the transaction backend which makes calls to the chatbot\'s API.',
  options:     {},
  state:       'Transaction::Chatbot',
  frontend:    false
)

# Setting 'chatbot_status' impiegato per abilitare/disabilitare l'uso del chatbot
# automatico sulla webchat nativa di Zammad
Setting.create_if_not_exists(
  title:       'Enable Chat-Bot',
  name:        'chatbot_status',
  area:        'Chat::Base',
  description: 'Enable/disable online chat-bot.',
  options:     {
    form: [
      {
        display: '',
        null:    true,
        name:    'chatbot_status',
        tag:     'boolean',
        options: {
          true  => 'yes',
          false => 'no',
        },
      },
    ],
  },
  preferences: {
    trigger:    ['menu:render', 'chat:rerender'],
    permission: ['admin.channel_chat'],
  },
  state:       true,
  frontend:    true
)

# Setting 'chat_bot_api_settings' che viene valorizzato con la URL
# della API che espone il servizio di risposta automatica
Setting.create_if_not_exists(
  title:       'Chat-Bot API URL',
  name:        'chat_bot_api_settings',
  area:        'System::Network',
  description: 'Use this section to set the Chat-Bot API URL.',
  options:     {
    form: [
      {
        display:     '',
        null:        false,
        name:        'chatbot_api_url',
        tag:         'input',
        placeholder: 'https://example.com/api/v1/service'
      },
    ],
  },
  preferences: {
    permission: ['admin.system'],
  },
  frontend:    true
)

# User 'chatbot@zammad.org'
User.create_if_not_exists(
  login:     'chatbot@zammad.org',
  firstname: 'Zimmy',
  lastname:  'Bot',
  email:     'chatbot@zammad.org',
  password:  '',
  active:    true,
  roles:     [ Role.find_by(name: 'Virtual Agent (Chatbot)') ]
)

Permission.create_if_not_exists(
  name:        'chat.supervisor',
  note:        'Access to %s',
  preferences: {
    translations: ['Chat'],
    not:          ['chat.customer'],
  },
)

# Creazione del role 'Supervisor'
Role.create_if_not_exists(
  name:              'Supervisor',
  note:              'To monitor the activity of the business.',
  default_at_signup: false,
  preferences:       {
    not: ['Customer'],
  },
  updated_by_id:     1,
  created_by_id:     1
)
supervisor = Role.lookup(name: 'Supervisor')

# Assegnazione delle permission al role 'Supervisor'
supervisor.permission_grant('user_preferences')
supervisor.permission_grant('ticket.agent')
supervisor.permission_grant('chat.agent')
supervisor.permission_grant('cti.agent')
supervisor.permission_grant('knowledge_base.reader')
supervisor.permission_grant('chat.supervisor')

# Assegnazione delle permission al role 'Admin'
admin = Role.find_by(name: 'Admin')
admin.permission_grant('chat.supervisor')

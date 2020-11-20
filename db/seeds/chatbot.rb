Setting.create_if_not_exists(
  title:       'Defines transaction backend.',
  name:        'Chatbot_transaction',
  area:        'Transaction::Backend::Async',
  description: 'Defines the transaction backend which makes calls to the chatbot\'s API.',
  options:     {},
  state:       'Transaction::Chatbot',
  frontend:    false
)

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

User.create_if_not_exists(
  login:           'chatbot@zammad.org',
  firstname:       'Zimmy',
  lastname:        'Bot',
  email:           'chatbot@zammad.org',
  password:        'turingtestpassed666',
  active:          true,
  roles:           [ Role.find_by(name: 'Agent') ]
)

Role.create_if_not_exists(
  id:                5,
  name:              'Supervisor',
  note:              'To manage business activity.',
  default_at_signup: false,
  preferences:       {
    not: ['Customer'],
  },
  updated_by_id:     1,
  created_by_id:     1
)

Permission.create_if_not_exists(
  name:        'chat.supervisor',
  note:        'Access to %s',
  preferences: {
    translations: ['Chat'],
    not:          ['chat.customer'],
  },
)

supervisor = Role.find_by(name: 'Supervisor')
supervisor.permission_grant('user_preferences')
supervisor.permission_grant('ticket.agent')
supervisor.permission_grant('chat.agent')
supervisor.permission_grant('cti.agent')
supervisor.permission_grant('knowledge_base.reader')
supervisor.permission_grant('chat.supervisor')
admin = Role.find_by(name: 'Admin')
admin.permission_grant('chat.supervisor')


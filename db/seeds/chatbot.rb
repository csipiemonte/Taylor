Setting.create_if_not_exists(
  title:       'Defines transaction backend.',
  name:        'Chatbot_transaction',
  area:        'Transaction::Backend::Async',
  description: 'Defines the transaction backend which makes calls to the chatbot\'s API.',
  options:     {},
  state:       'Transaction::Chatbot',
  frontend:    false
)

User.create_if_not_exists(
  login:           'chatbot@zammad.org',
  firstname:       'Chat',
  lastname:        'Bot',
  email:           'chatbot@zammad.org',
  password:        'turingtestpassed666',
  active:          true,
  roles:           [ Role.find_by(name: 'Agent') ]
)


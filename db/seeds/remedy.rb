Setting.create_if_not_exists(
  title:       'Defines transaction backend.',
  name:        'Remedy_transaction',
  area:        'Transaction::Backend::Async',
  description: 'Defines the transaction backend which makes calls to Remedy\'s API.',
  options:     {},
  state:       'Transaction::Remedy',
  frontend:    false
)
Setting.create_if_not_exists(
  title:       'Remedy Enviroment Variables',
  name:        'remedy_env_vars',
  area:        'Services',
  description: 'Defines Enviroment variables for Remedy API calls',
  options:     {},
  frontend:    false
)
Setting.create_if_not_exists(
  title:       'Remedy Ticket\'s State Mapping',
  name:        'remedy_ticket_state_mapping',
  area:        'Services',
  description: 'Defines Ticket Mappings between Remedy and Zammad',
  options:     {},
  state:       {
      nuovo: 1,
      assegnato: 2,
      pendente: 3,
      risolto: 4,
      chiuso: 4,
      annullato: 6,
     },
  frontend:    false
)
Ticket::Article::Type.create_if_not_exists(id: 13, name: 'remedy', communication: true)

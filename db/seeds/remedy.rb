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
Setting.create_if_not_exists(
  title:       'Remedy Integration',
  name:        'remedy_integration',
  area:        'Integration::Switch',
  description: 'Defines if Remedy integration is enabled or not.',
  options:     {
    form: [
      {
        display: '',
        null:    true,
        name:    'remedy_integration',
        tag:     'boolean',
        options: {
          true  => 'yes',
          false => 'no',
        },
      },
    ],
  },
  state:       true,
  preferences: {
    prio:           1,
    trigger:        ['menu:render', 'cti:reload'],
    authentication: true,
    permission:     ['admin.integration'],
  },
  frontend:    true
)
Setting.create_if_not_exists(
  title:       'Remedy Config',
  name:        'remedy_config',
  area:        'Integration::Remedy',
  description: 'Defines the Remedy Integration configurations.',
  options:     {},
  state:       { 'outbound' => { 'routing_table' => [], 'default_caller_id' => '' }, 'inbound' => { 'block_caller_ids' => [] } },
  preferences: {
    prio:       2,
    permission: ['admin.integration'],
  },
  frontend:    false,
)
Setting.create_if_not_exists(
  title:       'Remedy Token',
  name:        'remedy_token',
  area:        'Integration::Remedy',
  description: 'Token for Remedy.',
  options:     {
    form: [
      {
        display: '',
        null:    false,
        name:    'remedy_token',
        tag:     'input',
      },
    ],
  },
  preferences: {
    permission: ['admin.integration'],
  },
  frontend:    false
)
Setting.create_if_not_exists(
  title:       'Remedy Endpoint',
  name:        'remedy_endpoint',
  area:        'Integration::Remedy',
  description: 'Endpoint for Remedy.',
  options:     {
    form: [
      {
        display: '',
        null:    false,
        name:    'remedy_endpoint',
        tag:     'input',
      },
    ],
  },
  preferences: {
    permission: ['admin.integration'],
  },
  frontend:    false
)

Setting.find_by(name: 'Remedy_transaction').try(:destroy)


Setting.create_if_not_exists(
  title:       'Remedy Enviroment Variables',
  name:        'remedy_env_vars',
  area:        'Integration::Remedy',
  description: 'Defines Enviroment variables for Remedy API calls',
  options:     {},
  frontend:    false
)

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
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Remedy Ticket\'s Priority Mapping',
  name:        'remedy_ticket_priority_mapping',
  area:        'Integration::Remedy',
  description: 'Defines ticket\'s priorities mappings between Remedy and Zammad',
  options:     {},
  state:       {
    1 => 'Minimo/Localizzato-Bassa',
    2 => 'Moderato/Limitato-Media',
    3 => 'Significativo/Grande-Alta'
  },
  frontend:    false
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
  title:       'Remedy Base URL',
  name:        'remedy_base_url',
  area:        'Integration::Remedy',
  description: 'Remedy Base URL.',
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

Setting.create_if_not_exists(
  title:       'Remedy State Alignment',
  name:        'remedy_state_alignment',
  area:        'Integration::Remedy',
  description: 'Defines whether the aligner will align ticket states between Remedy and Zammad.',
  options:     {},
  state:       true,
  frontend:    false
)

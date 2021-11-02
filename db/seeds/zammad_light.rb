Setting.create_if_not_exists(
  title:       'Zammad Light Enviroment Variables',
  name:        'zammad_light_env_vars',
  area:        'Integration::ZammadLight',
  description: 'Defines Enviroment variables for Zammad Light API calls',
  options:     {},
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'ASL Integration',
  name:        'asl_integration',
  area:        'Integration::Switch',
  description: 'Defines if Zammad Light integration is enabled or not.',
  options:     {
    form: [
      {
        display: '',
        null:    true,
        name:    'asl_integration',
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
  title:       'Zammad Light Config',
  name:        'zammad_light_config',
  area:        'Integration::ZammadLight',
  description: 'Defines the Zammad Light Integration settings.',
  options:     {},
  state:       { 'outbound' => { 'routing_table' => [], 'default_caller_id' => '' }, 'inbound' => { 'block_caller_ids' => [] } },
  preferences: {
    prio:       2,
    permission: ['admin.integration'],
  },
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Zammad Light Token',
  name:        'asl_token',
  area:        'Integration::ZammadLight',
  description: 'Token for Zammad Light.',
  options:     {
    form: [
      {
        display: '',
        null:    false,
        name:    'asl_token',
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
  title:       'Zammad Light Base URL',
  name:        'asl_base_url',
  area:        'Integration::ZammadLight',
  description: 'Zammad Light Base URL.',
  options:     {
    form: [
      {
        display: '',
        null:    false,
        name:    'zammad_light_endpoint',
        tag:     'input',
      },
    ],
  },
  preferences: {
    permission: ['admin.integration'],
  },
  frontend:    false
)

User.create_if_not_exists(
  id:              5,
  login:           'zammad_light.agent@zammad.org',
  firstname:       'Zammad Light',
  lastname:        'Agent',
  email:           'zammad_light.agent@zammad.org',
  password:        '',
  active:          true,
  roles:           [ Role.find_by(name: 'Agent') ]
)

Setting.create_if_not_exists(
  title:       'Zammad Light State Alignment',
  name:        'asl_state_alignment',
  area:        'Integration::ZammadLight',
  description: 'Defines whether the aligner will align ticket states between Zammad Light and Zammad.',
  options:     {},
  state:       true,
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Zammad Light External Groups',
  name:        'asl_external_groups',
  area:        'Integration::ZammadLight',
  description: 'Defines ASL groups configured on ZammadLight. must be an array of hash with group id and name. Id MUST be equal to ZamamdLight group id.',
  options:     {},
  state:       [{ 'id': 1, 'name': 'ASL Alessandria' }],
  frontend:    false
)







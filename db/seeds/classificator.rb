Setting.create_if_not_exists(
  title:       'Defines postmaster filter.',
  name:        'ffff_classification_postmaster_filter_pre',
  area:        'Postmaster::PreFilter',
  description: 'Defines text-classification postmaster filter',
  options:     {},
  state:       'Channel::Filter::ClassificationFilter',
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Defines postmaster filter.',
  name:        'ffff_classification_postmaster_filter_post',
  area:        'Postmaster::PostFilter',
  description: 'Defines text-classification postmaster filter',
  options:     {},
  state:       'Channel::Filter::ClassificationFilter',
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'Classification Engine API URL',
  name:        'classification_engine_api_settings',
  area:        'System::Network',
  description: 'Use this section to set the Classification Engine API URL.',
  options:     {
    form: [
      {
        display: '',
        null:    false,
        name:    'classification_engine_api_url',
        tag:     'input',
        placeholder: 'https://example.com/api/v1/service'
      },
    ],
  },
  preferences: {
      prio:           16,
      trigger:        ['menu:render'],
      authentication: true,
    permission:       ['admin.system'],
  },
  frontend:    true
)
Setting.create_if_not_exists(
  title:       'Classification Engine Enabled',
  name:        'classification_engine_enabled',
  area:        'System::Network',
  description: 'Abilita il Classification Engine',
  options:     {
    form: [
      {
        display: '',
        null:    true,
        name:    'classification_engine_enabled',
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
    prio:           15,
    trigger:        ['menu:render'],
    authentication: true,
    permission:     ['admin.system'],
  },
  frontend:    true
)



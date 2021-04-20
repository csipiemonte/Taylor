# CSI attribute
ObjectManager::Attribute.add(
  force:       true,
  object:      'User',
  name:        'codice_fiscale',
  display:     'Codice Fiscale',
  data_type:   'input',
  data_option: {
    type:       'text',
    maxlength:  16,
    null:       true,
  },
  editable:    false,
  active:      true,
  screens:     {
    signup:          {},
    invite_agent:    {},
    invite_customer: {},
    edit:            {
      '-all-' => {
        null: true,
      },
    },
    view:            {
      '-all-' => {
        shown: true,
      },
    },
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    1820,
)


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



ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'utente_riconosciuto',
  display:     'Utente Riconosciuto',
  data_type:   'select',
  data_option: {
    default:    '',
    options:    {
      'no'           => 'No',
      'si'            => 'Si',
    },
    nulloption: true,
    multiple:   false,
    null:       true,
    # translate:  true,
  },
  editable:    true,
  active:      true,
  screens: { 
    'create_middle' => { 
      'ticket.customer' => { 
        'shown' => true, 
        'required' => true, 
        'item_class' => 'column' 
      },
      'ticket.agent'    => { 
        'shown' => true, 
        'required' => true, 
        'item_class' => 'column' 
      } 
    },
    'edit' => { 
      'ticket.customer' => { 
        'shown' => true, 
        'required' => true 
      },
      'ticket.agent' => { 
        'shown' => true, 
        'required' => true 
      } 
    } 
  },

  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    1830,
)



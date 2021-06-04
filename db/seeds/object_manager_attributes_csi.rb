# CSI attribute
ObjectManager::Attribute.add(
  force:       true,
  object:      'User',
  name:        'birthdate',
  display:     'Data di Nascita',
  data_type:   'date',
  data_option:  {    future:      false,
    past:        true, "diff"=>24, "default"=>nil, "null"=>true, "options"=>{}, "relation"=>""},
  data_option_new: {},
  editable:    false,
  active:      true,
  screens:     {
    "create"=> {
      "ticket.customer" => {"shown"=>true, "required"=>false},
      "ticket.agent" => {"shown"=>true, "required"=>false},
      "admin.user" => {"shown"=>true, "required"=>false}
    },
   "view" => {
     "ticket.customer "=> {"shown"=>true}, "ticket.agent" => {"shown"=>true}, "admin.user" => {"shown"=>true}
    },
   "edit" => {
     "ticket.agent" =>{"shown"=>true, "required"=>false}, "admin.user"=>{"shown"=>true, "required"=>false}
    },
   "signup" => {
     "ticket.customer" => {"shown"=>false, "required"=>false}
    },
   "invite_customer" => {
     "ticket.agent"=>{"shown"=>false, "required"=>false}, "admin.user"=>{"shown"=>false, "required"=>false}
    },
   "invite_agent" => {
     "admin.user"=>{"shown"=>false, "required"=>false}
    }
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  to_config: false,
  position:    1560,
)


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
  position:    1561,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'User',
  name:        'tessera_team',
  display:     'Tessera TEAM',
  data_type:   'input',
  data_option: {
    type:       'text',
    maxlength:  20,
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
  position:    1562,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'User',
  name:        'tessera_stp',
  display:     'Tessera STP',
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
  position:    1563,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'User',
  name:        'tessera_eni',
  display:     'Tessera ENI',
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
  position:    1564,
)



UtenteRiconosciutoLookup.create_if_not_exists(
  id:            1,
  value:         0,
  name:         "no"
)

UtenteRiconosciutoLookup.create_if_not_exists(
  id:            2,
  value:         1,
  name:         "si"
)
ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'utente_riconosciuto',
  display:     'Utente Riconosciuto',
  data_type:   'select',
  data_option: {
    default:    0,
    options:    {
      0           => UtenteRiconosciutoLookup.find_by(value: 0).name,
      1            => UtenteRiconosciutoLookup.find_by(value: 1).name,
    },
    nulloption: false,
    multiple:   false,
    null:       false,
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

ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'service_catalog_item_id',
  display:     'Service Catalog',
  data_type:   'select',
  data_option: {
    default:        '',
    options: {},
    autocapitalize: false,
    multiple:       false,
    guess:          true,
    null:           true,
    limit:          200,
    translate:      false,
    permission:     ['ticket.agent'],
  },
  editable:    false,
  active:      true,
  screens: {
    'create_middle' => {
      'ticket.agent'    => {
        'shown' => true,
        'required' => false,
        'item_class' => 'column'
      }
    },
    'edit' => {
      'ticket.agent' => {
        'shown' => false,
        'required' => false
      }
    }
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    1630,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'service_catalog_sub_item_id',
  display:     'Service Catalog Sub Item',
  data_type:   'select',
  data_option: {
    default:        '',
    options: {},
    autocapitalize: false,
    multiple:       false,
    guess:          true,
    null:           true,
    limit:          200,
    translate:      false,
    permission:     ['ticket.agent'],
  },
  editable:    false,
  active:      true,
  screens: {
    'create_middle' => {
      'ticket.agent'    => {
        'shown' => true,
        'required' => false,
        'item_class' => 'column'
      }
    },
    'edit' => {
      'ticket.agent' => {
        'shown' => false,
        'required' => false
      }
    }
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    1631,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'asset_id',
  display:     'Asset',
  data_type:   'select',
  data_option: {
    default:        '',
    options: {},
    autocapitalize: false,
    multiple:       false,
    guess:          true,
    null:           true,
    limit:          200,
    translate:      false,
    permission:     ['ticket.agent'],
  },
  editable:    false,
  active:      true,
  screens: {
    'create_middle' => {
      'ticket.agent'    => {
        'shown' => true,
        'required' => false,
        'item_class' => 'column'
      }
    },
    'edit' => {
      'ticket.agent' => {
        'shown' => false,
        'required' => false
      }
    }
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    1632,
)

ObjectManager::Attribute.add(
  force:       true,
  object:      'Ticket',
  name:        'type_id',
  display:     'Type',
  data_type:   'select',
  data_option: {
    default:    nil,
    options: Ticket::Type.all.map { |tt| [tt.id, tt.name] }.to_h,
    # options:    {
      # 'Incident'           => 'Incident',
      # 'Problem'            => 'Problem',
      # 'Request for Change' => 'Request for Change',
    # },
    nulloption: true,
    multiple:   false,
    null:       true,
    translate:  true,
  },
  editable:    false,
  active:      true,
  # screens:     {
  #   create_middle: {
  #     '-all-' => {
  #       null:       false,
  #       item_class: 'column',
  #     },
  #   },
  #   edit:          {
  #     'ticket.agent' => {
  #       null: false,
  #     },
  #   },
  # },
  screens: {
    'create_middle' => {
      'ticket.customer' => {
        'shown' => true,
        'required' => false,
        'item_class' => 'column'
      },
      'ticket.agent'    => {
        'shown' => true,
        'required' => false,
        'item_class' => 'column'
      }
    },
    'edit' => {
      'ticket.customer' => {
        'shown' => true,
        'required' => false
      },
      'ticket.agent' => {
        'shown' => true,
        'required' => false
      }
    }
  },
  to_create:   false,
  to_migrate:  false,
  to_delete:   false,
  position:    20,
)

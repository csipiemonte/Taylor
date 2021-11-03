ExternalTicketingSystem.create_if_not_exists(
  id:   1,
  name: 'Remedy'
)

person_id = Rails.env.casecmp('production').zero? ? 'PPL000000697192' : 'PPL000000426377'

# to update model just edit the following variable, then seed the database :)
remedy_model = {
  '0'  => {
    'name':                'remedy_id',
    'label':               'remedy id',
    'type':                'text',
    'receive_only':        true,
    'external_visibility': true
  },
  '1'  => {
    'required':   true,
    'type':       'text',
    'name':       'riepilogo',
    'label':      'riepilogo',
    'core_field': 'title'
  },
  '2'  => {
    'required':   true,
    'type':       'textarea',
    'name':       'dettaglio',
    'label':      'dettaglio',
    'core_field': 'body'
  },
  '3'  => {
    'name':                'stato',
    'label':               'stato',
    'type':                'text',
    'receive_only':         true,
    'external_visibility':  true,
    'editable_aftwerwards': true,
    'notify_changes': true,
    'closes_activity':      %w[Risolto Chiuso],
    'stop_monitoring':      %w[Annullato Chiuso],
      'select' => {
        'not_null': true,
        'options' => {
          '1' => { 'id': 'Nuovo', 'name': 'Nuovo', 'disabled': true },
          '2' => { 'id': 'Assegnato', 'name': 'Assegnato', 'disabled': true },
          '3' => { 'id': 'In corso', 'name': 'In corso', 'disabled': true },
          '4' => { 'id': 'Pendente', 'name': 'Pendente', 'disabled': true },
          '5' => { 'id': 'Risolto', 'name': 'Risolto' },
          '6' => { 'id': 'Chiuso', 'name': 'Chiuso', 'disabled': true },
          '7' => { 'id': 'Annullato', 'name': 'Annullato', 'disabled': true },
        }
      }
  },
  '4'  => {
    'required':  true,
    'name':     'impatto',
    'label':    'impatto',
    'default':  'Moderato/Limitato',
    'select' => {
      'options' => {
        '1' => { 'id': 'Minimo/Localizzato', 'name': 'Minimo/Localizzato' },
        '2' => { 'id': 'Moderato/Limitato', 'name': 'Moderato/Limitato' },
        '3' => { 'id': 'Significativo/Grande', 'name': 'Significativo/Grande' },
        '4' => { 'id': 'Vasto/Diffuso', 'name': 'Vasto/Diffuso' }
      }
    }
  },
  '5'  => {
    'required': true,
    'name':     'urgenza',
    'label':    'urgenza',
    'default':  'Media',
    'select' => {
      'options' => {
        '1' => { 'id': 'Bassa', 'name': 'Bassa' },
        '2' => { 'id': 'Media', 'name': 'Media' },
        '3' => { 'id': 'Alta', 'name': 'Alta' },
        '4' => { 'id': 'Critica', 'name': 'Critica' }
      }
    }
  },
  '6'  => {
    'required': true,
    'name':     'tipologia',
    'label':    'tipologia',
    'default':  'Ripristino di servizio utente',
    'select' => {
      'options' => {
        '1' => { 'id': 'Ripristino di servizio utente', 'name': 'Ripristino di servizio utente' },
      }
    }
  },
  '7'  => {
    'required':  true,
    'name':      'richiedente',
    'label':     'richiedente',
    'type':      'text',
    'default':   person_id,
    'read_only': true,
    'visible':   false
  },
  '8'  => {
    'required': true,
    'name':     'service_catalog',
    'label':    'Service Catalog',
    'select' => {
      'string_id': true,
      'service':   'service_catalog'
    }
  },
  '9'  => {
    'required': true,
    'name':     'service_catalog_sub_item',
    'label':    'Service Catalog Sub Item',
    'select' => {
      'string_id': true,
      'service':   'service_catalog_sub_item',
      'parent':    'service_catalog'
    }
  },
  '10' => {
    'required':   true,
    'name':       'asset',
    'label':      'Asset',
    'core_field': 'asset_id',
    'select' =>   {
      'string_id': true,
      'service':   'asset'
    }
  },
  '11' => {
    'name':          'commento',
    'label':         'commento',
    'type':          'comment',
    'attachments' => {
      'enabled': true
    }
  }
}

remedy_ticketing_system = ExternalTicketingSystem.find_by(name: 'Remedy')
remedy_current_model = remedy_ticketing_system['model']
if remedy_model != remedy_current_model
  remedy_ticketing_system['model'] = remedy_model
  remedy_ticketing_system.save!
end

ExternalTicketingSystem.create_if_not_exists(
  id:   2,
  name: 'ASL'
)

Setting.create_if_not_exists(
  title:       'Zammad Light External Groups',
  name:        'asl_external_groups',
  area:        'Integration::ZammadLight',
  description: 'Defines ASL groups configured on ZammadLight. must be an array of hash with group id and name. Id MUST be equal to ZamamdLight group id.',
  options:     {},
  state:       [
    { 'id': 2, 'name': 'ASL Alessandria' },
    { 'id': 3, 'name': 'ASL Biella' },
    { 'id': 4, 'name': 'ASL Novara' },
  ],
  frontend:    false
)

# to update model just edit the following variable, then seed the database :)
zammad_light_model = {
  '0' => {
    'name':                'zammad_light_id',
    'label':               'zammad light id',
    'type':                'text',
    'receive_only':        true,
    'external_visibility': true
  },
  '1' => {
    'required':   true,
    'type':       'text',
    'name':       'title',
    'label':      'titolo',
    'core_field': 'title'
  },
  '2' => {
    'type':       'text',
    'name':       'subject',
    'label':      'oggetto',
    'core_field': 'subject'
  },
  '3' => {
    'name':                'state',
    'label':               'stato',
    'type':                'text',
    'receive_only':         true,
    'external_visibility':  true,
    'editable_aftwerwards': true,
    'notify_changes':       true,
    'closes_activity':      [ '4', '6' ],
    'stop_monitoring':      [ '4', '6' ],
      'select' => {
        'not_null': true,
        'options' => {
          '1' => { 'id': 1, 'name': 'Nuovo', 'disabled': true },
          '2' => { 'id': 2, 'name': 'Aperto', 'disabled': true },
          '4' => { 'id': 3, 'name': 'In attesa di', 'disabled': true },
          '6' => { 'id': 4, 'name': 'Chiuso' },
          '7' => { 'id': 7, 'name': 'In attesa di chiusura', 'disabled': true },
        }
      }
  },
  '4' => {
    'required':   true,
    'type':       'textarea',
    'name':       'body',
    'label':      'richiesta',
    'core_field': 'body'
  },
  '5' => {
    'name':     'priority',
    'label':    'priority',
    'default':  2,
    'select' => {
      'options' => {
        '1' => { 'id': 1, 'name': 'Bassa' },
        '2' => { 'id': 2, 'name': 'Normale' },
        '3' => { 'id': 3, 'name': 'Alta' },
      }
    }
  },
  '6' => {
    'required':  true,
    'name':      'customer',
    'label':     'customer',
    'type':      'text',
    'default':   'nextcrm.agent@csi.it',
    'read_only': true,
    'visible':   false
  },
  '7' => {
    'required':  true,
    'name':      'group_id',
    'label':     'group_id',
    'default':  1,
    'select' => {
      'options' => Setting.get('asl_external_groups').each_with_index.map { |group, index| ["#{index+1}", group] }.to_h
    },
    'visible':   true
  },
  '8' => {
    'name':  'commento',
    'label': 'commento',
    'type':  'comment',
    'attachments' => {
      'enabled': true
    }
  }
}

zammad_light_ticketing_system = ExternalTicketingSystem.find_by(name: 'ASL')
zammad_light_current_model = zammad_light_ticketing_system['model']
if zammad_light_model != zammad_light_current_model
  zammad_light_ticketing_system['model'] = zammad_light_model
  zammad_light_ticketing_system.save!
end

def create_translation(locale, source, target)
  Translation.create_if_not_exists(
    locale:         locale,
    source:         source,
    target:         target,
    target_initial: target,
    format:         'string',
    created_by_id:  '1',
    updated_by_id:  '1',
  )
end

['en-ca', 'en-gb', 'en-us', 'uk'].each do |en_locale|
  create_translation(en_locale, 'Service Catalog', 'Service')
  create_translation(en_locale, 'Service Catalog Sub Item', 'Service Detail')
  create_translation(en_locale, 'Asset', 'Application')
end

create_translation('it-it', 'Service Catalog', 'Servizio')
create_translation('it-it', 'Service Catalog Sub Item', 'Dettaglio Servizio')
create_translation('it-it', 'Asset', 'Applicazione')

create_translation('it-it', 'Get Updates', 'Ricevi Aggiornamenti')
create_translation('it-it', 'Get activity updates from the external system', 'Ricevi gli aggiornamenti dell\'attività dal sistema esterno')
create_translation('it-it', '✎ Import data from user\'s ticket', '✎ Importa dati da richiesta utente')
create_translation('it-it', 'External activity', 'Attività Esterna')
create_translation('it-it', 'New external activity on', 'Nuova attività esterna su')

create_translation('it-it', 'crm operator', 'operatore crm')
create_translation('it-it', 'external operator', 'operatore esterno')

create_translation('it-it', 'Update on an external activity related to Ticket |%s|', 'C\'è un aggiornamento su un\'attività esterna legata al Ticket |%s|')
create_translation('it-it', '⚠ There are new changes on this activity', '⚠ Ci sono aggiornamenti su questa attività')
create_translation('it-it', 'Needs Attention', 'Richiede Attenzione')

create_translation('it-it', 'No ticketing systems available', 'Nessun ticketing system esterno disponibile')

Setting.create_if_not_exists(
  title:       'External Activity Public Visibility',
  name:        'external_activity_public_visibility',
  area:        'Integration::Remedy',
  description: 'For each external ticketing system specifies whether external activities are included in tickets fetched by individual virtual operators',
  options:     {},
  state:       {},
  frontend:    false
)

Setting.create_if_not_exists(
  title:       'External Activity Group Access',
  name:        'external_activity_group_access',
  area:        'Integration::Remedy',
  description: 'For each external ticketing system specifies read/write permissions for groups on activities',
  options:     {},
  state:       {},
  frontend:    false
)

create_translation('it-it', 'group_id', 'Gruppo')
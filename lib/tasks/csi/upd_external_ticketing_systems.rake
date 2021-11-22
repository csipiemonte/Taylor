namespace :csi do

  desc 'Update external ticketing systems'
  task :upd_external_ticketing_systems => :environment do

    person_id = Rails.env.casecmp('production').zero? ? 'PPL000000697192' : 'PPL000000426377'
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
    remedy_ticketing_system['model'] = remedy_model
    remedy_ticketing_system.save!

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
      '3' => {
        'required':   true,
        'type':       'textarea',
        'name':       'body',
        'label':      'richiesta',
        'core_field': 'body'
      },
      '4' => {
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
      '5' => {
        'required':  true,
        'name':      'customer',
        'label':     'customer',
        'type':      'text',
        'default':   'nextcrm.agent@csi.it',
        'read_only': true,
        'visible':   false
      },
      '6' => {
        'required':  true,
        'name':      'group_id',
        'label':     'group_id',
        'default':  2,
        'select' => {
          'options' => {
            '1' => { 'id': 2, 'name': 'ASL Alessandria' },
            '2' => { 'id': 3, 'name': 'ASL Biella' },
            '3' => { 'id': 4, 'name': 'ASL Novara' },
          }
        },
        'visible':   true
      },
      '7' => {
        'name':  'commento',
        'label': 'commento',
        'type':  'comment',
        'attachments' => {
          'enabled': true
        }
      }
    }

    zammad_light_ticketing_system = ExternalTicketingSystem.find_by(name: 'ASL')
    zammad_light_ticketing_system['model'] = zammad_light_model
    zammad_light_ticketing_system.save!
  end
end

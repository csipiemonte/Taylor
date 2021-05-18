ExternalTicketingSystem.create_if_not_exists(
  id: 1,
  name: 'Remedy'
)

# to update model just edit the following variable, then seed the database :)
remedy_model = {
  '1' => {
      'required': true,
      'name':'riepilogo',
      'label':'riepilogo',
      'core_field':'title'
  },
  '2' => {
      'required': true,
      'type':'text',
      'name':'dettaglio',
      'label':'dettaglio'
  },
  '3' => {
      'required': true,
      'name':'impatto',
      'label':'impatto',
      'select' => {
          'options' => {
              '1' => {'id':'Minimo/localizzato', 'name':'Minimo/localizzato'},
              '2' => {'id':'Moderato/limitato', 'name':'Moderato/limitato'},
              '3' => {'id':'Significativo/grande', 'name':'Significativo/grande'},
              '4' => {'id':'Vasto/diffuso', 'name':'Vasto/diffuso'}
          }
      }
  },
  '4' => {
      'required': true,
      'name':'urgenza',
      'label':'urgenza',
      'select' => {
          'options' => {
              '1' => {'id':'Bassa', 'name':'Bassa'},
              '2' => {'id':'Media', 'name':'Media'},
              '3' => {'id':'Alta', 'name':'Alta'},
              '4' => {'id':'Critica', 'name':'Critica'}
          }
      }
  },
  '5' => {
      'required': true,
      'name':'tipologia',
      'label':'tipologia',
      'select' => {
          'options' => {
              '1' => {'id':'Richiesta utente', 'name':'Richiesta utente'},
              '2' => {'id':'Ripristino di servizio utente', 'name':'Ripristino di servizio utente'}
          }
      }
  },
  '6' => {
      'required': true,
      'name':'richiedente',
      'label':'richiedente',
      'type':'text',
      'default':'PPL000000018476',
      'read_only': true,
      'visible': false
  },
  '7' => {
      'required': true,
      'name':'service_catalog',
      'label':'service catalog',
      'select' => {
          'service': 'service_catalog'
      }
  },
  '8' => {
      'required': true,
      'name':'service_catalog_sub_item',
      'label':'service catalog sub item',
      'select' => {
          'service': 'service_catalog_sub_item',
          'parent': 'service_catalog'
      }
  },
  '9' => {
      'required': true,
      'name':'asset',
      'label':'asset',
      'core_field': 'asset_id',
      'select' => {
          'service': 'asset'
      }
  }
}

remedy_ticketing_system = ExternalTicketingSystem.find_by(name: 'Remedy')
remedy_current_model = remedy_ticketing_system["model"]
if remedy_model != remedy_current_model
  remedy_ticketing_system["model"] = remedy_model
  remedy_ticketing_system.save!
end


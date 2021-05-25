ExternalTicketingSystem.create_if_not_exists(
  id: 1,
  name: 'Remedy'
)

# to update model just edit the following variable, then seed the database :)
remedy_model = {
  '0' => {
    'name':'remedy_id',
    'label':'remedy id',
    'type':'text',
    'receive_only': true
    },
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
      'label':'dettaglio',
      'core_field':'body'
  },
  '3' => {
    'name':'stato',
    'label':'stato',
    'type':'text',
    'receive_only': true
    },
  '4' => {
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
  '5' => {
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
  '6' => {
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
  '7' => {
      'required': true,
      'name':'richiedente',
      'label':'richiedente',
      'type':'text',
      'default':'PPL000000018476',
      'read_only': true,
      'visible': false
  },
  '8' => {
      'required': true,
      'name':'service_catalog',
      'label':'Service Catalog',
      'select' => {
          'service': 'service_catalog'
      }
  },
  '9' => {
      'required': true,
      'name':'service_catalog_sub_item',
      'label':'Service Catalog Sub Item',
      'select' => {
          'service': 'service_catalog_sub_item',
          'parent': 'service_catalog'
      }
  },
  '10' => {
      'required': true,
      'name':'asset',
      'label':'Asset',
      'core_field': 'asset_id',
      'select' => {
          'service': 'asset'
      }
  },
  '11' => {
    'name':'commento',
    'label':'commento',
    'type':'comment'
    }
}

remedy_ticketing_system = ExternalTicketingSystem.find_by(name: 'Remedy')
remedy_current_model = remedy_ticketing_system['model']
if remedy_model != remedy_current_model
  remedy_ticketing_system['model'] = remedy_model
  remedy_ticketing_system.save!
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


['en-ca','en-gb','en-us','uk'].each do |en_locale|
  create_translation(en_locale,'Service Catalog','Service')
  create_translation(en_locale,'Service Catalog Sub Item','Service Detail')
  create_translation(en_locale,'Asset','Application')
end

create_translation('it-it','Service Catalog','Servizio')
create_translation('it-it','Service Catalog Sub Item','Dettaglio Servizio')
create_translation('it-it','Asset','Applicazione')

create_translation('it-it','Get Updates','Ricevi Aggiornamenti')
create_translation('it-it','Get activity updates from the external system','Ricevi gli aggiornamenti dell\'attività dal sistema esterno')
create_translation('it-it','✎ Import data from user\'s ticket','✎ Importa dati da richiesta utente')
create_translation('it-it','External activity','Attività Esterna')
create_translation('it-it','New external activity on','Nuova attività esterna su')

create_translation('it-it','crm operator','operatore crm')
create_translation('it-it','external operator','operatore esterno')







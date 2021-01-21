Setting.create_if_not_exists(
  title:       'Defines transaction backend.',
  name:        'Remedy_transaction',
  area:        'Transaction::Backend::Async',
  description: 'Defines the transaction backend which makes calls to Remedy\'s API.',
  options:     {},
  state:       'Transaction::Remedy',
  frontend:    false
)
Setting.create_if_not_exists(
  title:       'Remedy Enviroment Variables',
  name:        'remedy_env_vars',
  area:        'Services',
  description: 'Defines Enviroment variables for Remedy API calls',
  options:     {},
  state:       {
      access_token: 'f9b12cd4-16f3-3956-96fa-2f288667b9f3',
      base_url: 'https://tst-api-piemonte.ecosis.csi.it/tecno/troubleticketing/v1',
      request_id:'zammad_to_remedy',
      forwarded_for:'127.0.0.1'
     },
  frontend:    false
)
Setting.create_if_not_exists(
  title:       'Remedy Ticket\'s State Mapping',
  name:        'remedy_ticket_state_mapping',
  area:        'Services',
  description: 'Defines Ticket Mappings between Remedy and Zammad',
  options:     {},
  state:       {
      nuovo: 1,
      assegnato: 2,
      pendente: 3,
      risolto: 4,
      chiuso: 4,
      annullato: 6,
     },
  frontend:    false
)

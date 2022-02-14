# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

Ticket::Priority.create_if_not_exists(id: 1, name: '1 high', ui_icon: 'important', ui_color: 'high-priority')
Ticket::Priority.create_if_not_exists(id: 2, name: '2 normal', default_create: true)
Ticket::Priority.create_if_not_exists(id: 3, name: '3 low',  ui_icon: 'low-priority', ui_color: 'low-priority')
Ticket::Priority.create_if_not_exists(id: 4, name: '4 mild', ui_icon: 'low-priority', ui_color: 'low-priority')

######################
#### Translations ####
######################

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         '1 high',
  target:         '1 alta',
  target_initial: '1 alta',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         '2 normal',
  target:         '2 normale',
  target_initial: '2 normale',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         '3 low',
  target:         '3 bassa',
  target_initial: '3 bassa',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)

Translation.create_if_not_exists(
  locale:         'it-it',
  source:         '4 mild',
  target:         '4 lieve',
  target_initial: '4 lieve',
  format:         'string',
  created_by_id:  '1',
  updated_by_id:  '1',
)
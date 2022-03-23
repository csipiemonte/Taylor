# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

Ticket::Priority.create_if_not_exists(id: 1, name: __('critical'), ui_icon: 'important', ui_color: 'high-priority')
Ticket::Priority.create_if_not_exists(id: 2, name: __('high'), ui_icon: 'important', ui_color: 'high-priority')
Ticket::Priority.create_if_not_exists(id: 3, name: __('medium'), default_create: true)
Ticket::Priority.create_if_not_exists(id: 4, name: __('low'), ui_icon: 'low-priority', ui_color: 'low-priority')
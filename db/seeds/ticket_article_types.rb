# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

Ticket::Article::Type.create_if_not_exists(id: 1, name: __('email'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 2, name: __('sms'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 3, name: __('chat'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 4, name: __('fax'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 5, name: __('phone'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 6, name: __('twitter status'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 7, name: __('twitter direct-message'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 8, name: __('facebook feed post'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 9, name: __('facebook feed comment'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 10, name: __('note'), communication: false)
Ticket::Article::Type.create_if_not_exists(id: 11, name: __('web'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 12, name: __('telegram personal-message'), communication: true)

# CSI channels - inizio
Ticket::Article::Type.create_if_not_exists(id: 13, name: __('web (via api)'), communication: true)
Ticket::Article::Type.create_if_not_exists(id: 14, name: __('phone (via api)'), communication: true)
# CSI channels - fine

Ticket::Article::Type.create_if_not_exists(id: 15, name: __('facebook direct-message'), communication: true)
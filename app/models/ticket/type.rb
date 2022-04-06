# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/
class Ticket::Type < ApplicationModel
  include CanBeImported
  include HasCollectionUpdate

  self.table_name = 'ticket_types'
end

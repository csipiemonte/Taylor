# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class Sequencer
  class Sequence
    module Import
      module Freshdesk
        class TicketField < Sequencer::Sequence::Base

          def self.sequence
            [
              'Common::ModelClass::Ticket',
              'Import::Freshdesk::ObjectAttribute::Skip',
              'Import::Freshdesk::ObjectAttribute::SanitizedName',
              'Import::Freshdesk::ObjectAttribute::Config',
              'Import::Freshdesk::ObjectAttribute::Add',
              'Import::Freshdesk::ObjectAttribute::MigrationExecute',
              'Import::Freshdesk::ObjectAttribute::FieldMap',
            ]
          end
        end
      end
    end
  end
end

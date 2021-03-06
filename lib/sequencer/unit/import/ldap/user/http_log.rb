# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class Sequencer
  class Unit
    module Import
      module Ldap
        module User
          class HttpLog < Import::Common::Model::HttpLog
            private

            def facility
              'ldap'
            end
          end
        end
      end
    end
  end
end

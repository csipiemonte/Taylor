# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

require 'rails_helper'
require 'system/examples/pagination_examples'

RSpec.describe 'Manage > Role', type: :system do
  context 'ajax pagination' do
    include_examples 'pagination', model: :role, klass: Role, path: 'manage/roles'
  end
end

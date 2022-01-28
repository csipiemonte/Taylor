# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

class CoreWorkflow::Attributes::ServiceCatalogSubItem < CoreWorkflow::Attributes::Base
  def values
    @values ||= items = ServiceCatalogSubItem.where(parent_service: @attributes.payload['params']['service_catalog_item_id']).pluck(:id)
  end
end

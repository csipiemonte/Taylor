class ServiceCatalogItem < ApplicationModel
  has_many :mappings,  class_name: 'ServiceCatalogSubItem'
end

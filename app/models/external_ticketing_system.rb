class ExternalTicketingSystem < ApplicationModel
  has_many :mappings,  class_name: 'ExternalActivity'
  store :model
end

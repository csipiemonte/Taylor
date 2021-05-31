class ExternalTicketingSystem < ApplicationModel
  has_many :mappings,  class_name: 'ExternalTicketingSystem'
  store :model

  validates :name, presence: true
end

class TicketCategorization < ApplicationModel
  has_many :mappings,  class_name: 'RemedyTripleMapping'
end

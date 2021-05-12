class ExternalActivity < ApplicationModel
  belongs_to :ticket
  belongs_to :external_ticketing_system
  store :data
end

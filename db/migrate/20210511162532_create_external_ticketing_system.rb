class CreateExternalTicketingSystem < ActiveRecord::Migration[5.2]
  def change
    create_table :external_ticketing_system do |t|
      t.string  :name
      t.string  :model
      t.string  :icon_path
      t.timestamps
    end
  end
end

class CreateExternalTicketingSystem < ActiveRecord::Migration[5.2]
  def change
    create_table :external_ticketing_systems do |t|
      t.string  :name
      t.text  :model
      t.string  :icon_path
      t.timestamps
    end
  end
end

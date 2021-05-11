class CreateExternalActivity < ActiveRecord::Migration[5.2]
  def change
    create_table :external_activity do |t|
      t.integer  :external_ticketing_system_id
      t.integer  :ticket_id
      t.string  :data
      t.string  :bidirectional_alignment
      t.timestamps
    end
    add_foreign_key :external_activity, :external_ticketing_system, column: :external_ticketing_system_id
    add_foreign_key :external_activity, :tickets, column: :ticket_id
  end
end

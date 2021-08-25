class CreateExternalActivity < ActiveRecord::Migration[5.2]
  def change
    create_table :external_activities do |t|
      t.integer  :external_ticketing_system_id, null:false
      t.integer  :ticket_id, null:false
      t.text  :data
      t.boolean  :bidirectional_alignment, default:true
      t.timestamps
    end
    add_foreign_key :external_activities, :external_ticketing_systems, column: :external_ticketing_system_id
    add_foreign_key :external_activities, :tickets, column: :ticket_id
  end
end

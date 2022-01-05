class AddCascadeDeleteExternalActivity < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        remove_foreign_key :external_activities, column: :ticket_id
        add_foreign_key :external_activities, :tickets, column: :ticket_id, on_delete: :cascade
      end
      dir.down do
        remove_foreign_key :external_activities, column: :ticket_id
        add_foreign_key :external_activities, :tickets, column: :ticket_id
      end
    end
  end
end

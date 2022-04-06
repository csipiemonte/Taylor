class CreateTicketTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :ticket_types do |t|
      t.string  :name
      t.timestamps
    end
    add_column :tickets, :type_id, :integer
    add_foreign_key :tickets, :ticket_types, column: :type_id
  end
end

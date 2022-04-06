class AddExternalStateIdToTicketState < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_states, :external_state_id, :integer
    add_foreign_key :ticket_states, :ticket_states, column: :external_state_id
  end
end

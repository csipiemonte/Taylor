class AddRemedyIdToTicketSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :ticket_sessions, :remedy_ticket, :string
  end
end

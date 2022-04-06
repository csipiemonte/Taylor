class AddRemedyIdToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :remedy_ticket, :string
  end
end

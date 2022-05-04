class AddSolicitNumberToTicket < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :solicit_number, :integer, default: 0
  end
end

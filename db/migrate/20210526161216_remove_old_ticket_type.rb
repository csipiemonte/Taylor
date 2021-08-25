class RemoveOldTicketType < ActiveRecord::Migration[5.2]
  def change
    remove_column :tickets, :type
    # remove_column :table_name, :column_name
  end
end

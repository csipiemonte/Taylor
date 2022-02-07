class RenameTypeId < ActiveRecord::Migration[6.0]
  def change
    rename_column :tickets, :type_id, :ticket_type_id
  end
end

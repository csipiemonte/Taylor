class FixColumnName < ActiveRecord::Migration[5.2]
  def self.up
    rename_column :tickets, :remedy_ticket, :remedy_id
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end

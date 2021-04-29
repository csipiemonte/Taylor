class AddCategorizationFieldToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :service_catalog_item_id, :integer
    add_foreign_key :tickets, :service_catalog_item, column: :service_catalog_item_id
    add_column :tickets, :service_catalog_sub_item_id, :integer
    add_foreign_key :tickets, :service_catalog_sub_item, column: :service_catalog_sub_item_id
    add_column :tickets, :asset_id, :integer
    add_foreign_key :tickets, :asset, column: :asset_id
  end
end

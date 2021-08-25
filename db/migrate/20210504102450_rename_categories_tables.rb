class RenameCategoriesTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :service_catalog_item, :service_catalog_items
    rename_table :service_catalog_sub_item, :service_catalog_sub_items
    rename_table :asset, :assets
  end
end

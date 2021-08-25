class CreateServiceCatalogSubItem < ActiveRecord::Migration[5.2]
  def change
    create_table :service_catalog_sub_item do |t|
      t.integer :parent_service
      t.string  :name
      t.timestamps
    end
    add_foreign_key :service_catalog_sub_item, :service_catalog_item, column: :parent_service
  end
end

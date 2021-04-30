class CreateServiceCatalogItem < ActiveRecord::Migration[5.2]
  def change
    create_table :service_catalog_item do |t|
      t.string  :name
      t.timestamps
    end
  end
end

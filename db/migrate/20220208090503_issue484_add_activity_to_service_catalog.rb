class Issue484AddActivityToServiceCatalog < ActiveRecord::Migration[6.0]
  def change
    add_column :service_catalog_items, :crm, :integer
    add_column :service_catalog_items, :itsm, :integer
    add_column :service_catalog_sub_items, :crm, :integer
    add_column :service_catalog_sub_items, :itsm, :integer
  end
end

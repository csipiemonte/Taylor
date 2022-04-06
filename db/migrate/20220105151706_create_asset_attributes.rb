class CreateAssetAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :asset_attributes do |t|
      t.string   :name
      t.string   :value

      t.integer  :asset_id, null: false

      t.timestamps
    end
    add_foreign_key :asset_attributes, :assets, column: :asset_id
  end
end

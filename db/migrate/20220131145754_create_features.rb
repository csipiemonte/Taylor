class CreateFeatures < ActiveRecord::Migration[6.0]
  def change
    create_table :features do |t|
      t.string    :name
      t.boolean   :enabled,  null: false, default: false
      
      t.timestamps
    end
  end
end

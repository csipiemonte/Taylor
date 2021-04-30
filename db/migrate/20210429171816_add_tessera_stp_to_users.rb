class AddTesseraStpToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tessera_stp, :string
    add_index :users, :tessera_stp, unique: true
  end
end

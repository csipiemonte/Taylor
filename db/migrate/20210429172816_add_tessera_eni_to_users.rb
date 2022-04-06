class AddTesseraEniToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tessera_eni, :string
    add_index :users, :tessera_eni, unique: true
  end
end

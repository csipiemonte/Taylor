class AddCodiceFiscaleToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :codice_fiscale, :string
    add_index :users, :codice_fiscale, unique: true
  end
end

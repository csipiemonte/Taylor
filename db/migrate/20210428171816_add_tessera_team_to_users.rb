class AddTesseraTeamToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :tessera_team, :string
    add_index :users, :tessera_team, unique: true
  end
end

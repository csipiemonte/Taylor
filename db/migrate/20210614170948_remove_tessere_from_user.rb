class RemoveTessereFromUser < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :tessera_team
    remove_column :users, :tessera_eni
    remove_column :users, :tessera_stp
  end
end

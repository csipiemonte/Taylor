class AddVerifiedDataToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :verified_data, :boolean, null: false, default: false
  end
end

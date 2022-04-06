class AddEmailToAuthorizations < ActiveRecord::Migration[5.2]
  def change
    add_column :authorizations, :email, :string
    add_index :authorizations, :email, unique: true
  end
end

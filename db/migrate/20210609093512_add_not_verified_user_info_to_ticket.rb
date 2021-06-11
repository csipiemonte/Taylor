class AddNotVerifiedUserInfoToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :not_verified_user_firstname, :string
    add_column :tickets, :not_verified_user_lastname, :string
    add_column :tickets, :not_verified_user_codice_fiscale, :string
    add_column :tickets, :not_verified_user_mobile, :string
    add_column :tickets, :not_verified_user_phone, :string
  end
end

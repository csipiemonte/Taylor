class AddContactInfoToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :notification_email, :string
    add_column :tickets, :recall_phone, :string
  end
end

class AddAdditionalInfoToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :additional_info, :string
  end
end

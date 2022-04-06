class RemoveTicketCategorizations < ActiveRecord::Migration[5.2]
  def change
    drop_table :ticket_categorizations do |t|
    end
  end
end

class CreateTicketCategorizations < ActiveRecord::Migration[5.2]
  def change
    create_table :ticket_categorizations do |t|
      t.string :level_1
      t.string :level_2

      t.timestamps
    end
  end
end

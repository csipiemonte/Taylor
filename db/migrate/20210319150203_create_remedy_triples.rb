class CreateRemedyTriples < ActiveRecord::Migration[5.2]
  def change
    create_table :remedy_triples do |t|
      t.string :level_1
      t.string :level_2
      t.string :level_3

      t.timestamps
    end
  end
end

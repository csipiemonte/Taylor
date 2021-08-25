class CreateRemedyTripleMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :remedy_triple_mappings do |t|
      t.integer :remedy_triple_id
      t.integer :ticket_categorization_id
      t.timestamps
    end
  end
end

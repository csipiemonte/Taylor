class MappingsForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :remedy_triple_mappings, :remedy_triples, column: :remedy_triple_id
    add_foreign_key :remedy_triple_mappings, :ticket_categorizations, column: :ticket_categorization_id
  end
end

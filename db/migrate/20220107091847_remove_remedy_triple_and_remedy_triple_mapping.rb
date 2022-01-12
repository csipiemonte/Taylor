class RemoveRemedyTripleAndRemedyTripleMapping < ActiveRecord::Migration[5.2]
  def change
    drop_table :remedy_triple_mappings do |t|
    end
    drop_table :remedy_triples do |t|
    end
  end
end

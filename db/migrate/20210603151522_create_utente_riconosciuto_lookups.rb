class CreateUtenteRiconosciutoLookups < ActiveRecord::Migration[5.2]
  def change
    create_table :utente_riconosciuto_lookups do |t|
      t.integer :value
      t.string  :name
      t.timestamps
    end
  end
end

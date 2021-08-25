class AddUtenteRiconosciutoToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :utente_riconosciuto, :string
  end
end

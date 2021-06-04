class ChangeUtenteRiconosciutoType < ActiveRecord::Migration[5.2]
  def up
    Ticket.all.each do |t|
      case t.utente_riconosciuto
        when "si", "Si","yes","Yes"
          t.update_attribute :utente_riconosciuto, "1"
        else
          t.update_attribute :utente_riconosciuto, "0"
      end
    end
    change_table :tickets do |t|
      t.change :utente_riconosciuto, 'integer USING CAST(utente_riconosciuto AS integer)'
    end
    
  end
  def down
    change_table :users do |t|
      t.change :utente_riconosciuto, :string
    end
  end
end

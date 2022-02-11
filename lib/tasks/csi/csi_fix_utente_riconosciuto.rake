namespace :csi do
    task :fix_utente_riconosciuto => :environment do
        Ticket.where(utente_riconosciuto: nil).find_each do |t|
          t.utente_riconosciuto = 0
          t.save!
        end
    end
end
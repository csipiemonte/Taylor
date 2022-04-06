namespace :csi do
    task :export_tickets => :environment do
        Rails.logger = Logger.new(STDOUT)
        logger = Rails.logger

        timestamp = Time.now.strftime("%Y%m%d%H%M%S")
        file_name = "#{Rails.root}/log/#{timestamp}_export.csv"
        dump_data = nil

      
        csv_options = {}
        csv_header_row = %w(id title nunmber note created_at group state priority customer first_article_body)
        processed_tickets = 0
        total_tickets = Ticket.all.count

        Ticket.includes(:group,:state,:priority,:customer,:articles).order(:id).in_batches(of: 100) do |relation|
            
            dump_data = CSV.generate(csv_options) do |csv_file|
                csv_file << csv_header_row if processed_tickets == 0
                begin
                    relation.each do |t|
                        csv_file << [t.id, t.title, t.number, t.note, t.created_at, t.group.name, t.state.name, t.priority.name, t.customer.email, t.articles.first.body]
                    end
                rescue => e
                    Rails.logger.error e
                end
            end

            processed_tickets += relation.count
            logger.info{"processed tickets: #{processed_tickets}/#{total_tickets}"}
    
     
            File.write(file_name, dump_data, mode: "a")
        end

    end
end
namespace :csi do
    task :create_sample_unomi_events => :environment do
        Rails.logger = Logger.new(STDOUT)
        logger = Rails.logger

        session_id = 1234

        def generate_event_data eventType, scope, source_name, source_type, description, nps_score
            result = {
                "eventType"=> eventType,
                "scope"=> scope,
                "source"=>{
                    "scope"=> scope,
                    "itemId"=> source_name,
                    "itemType"=> source_type,
                    "properties" => {
                        'name' => source_name
                    }
                },
                "properties" => {}
            }
            result['properties']['description'] = description if description && !description.to_s.empty?
            result['properties']['NPS_score'] = nps_score.to_f if nps_score && !nps_score.to_s.empty?
            result
        end

        url = 'https://ts-nextcrm-unomi-bo-api.preprod.nivolapiemonte.it/eventcollector'
        headers = {
            'Content-Type' => 'application/json'
        }

        event_data = {
            "sessionId" => session_id,
            "events" => []
        }

        event_list = [
            ['Feedback','Sanità','sansol','Applicazione Backend', 'Feedback rilasciato da utente', 2]
        ]
        # csv_filename = './lib/tasks/csi/csi_create_sample_unomi_events.csv'
        # require 'csv'    
        # event_list = CSV.read(csv_filename, :headers => true)


        # event_list.each_with_index do |e, index|
        #     event_data['events'] << generate_event_data(e[0], e[1], e[2], e[3], e[4], e[5])
        # end

        # response = Faraday.post url, event_data.to_json, headers
        # puts response.status
        # puts response.body

        event_list.each_with_index do |e, index|
            this_event_data << generate_event_data(e[0], e[1], e[2], e[3], e[4], e[5])
            response = Faraday.post url, this_event_data.to_json, headers
            if response.success?
                puts "Created event #{index}/#{event_list.length}"
            else
                puts "ERROR on event #{index}/#{event_list.length}. Status: #{response.status}. Body: #{response.body}"
            end
            sleep 69
        end

        
    end
end
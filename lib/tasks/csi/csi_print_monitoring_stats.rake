namespace :csi do
    task :print_monitoring_stats => :environment do
        Rails.logger = Logger.new("#{Rails.root}/log/print_monitoring_stats.log", 3, 20*1048576)
        #Rails.logger = Logger.new(STDOUT)

        delayed_jobs_count = Delayed::Job.count
        delayed_jobs_failures = Delayed::Job.where('attempts != 0').pluck(:handler).map{|a| YAML.load(a).to_json}

        zammad_monitoring_token = Setting.get('monitoring_token')
        uri = URI("http://localhost:3000/api/v1/monitoring/health_check?token=#{zammad_monitoring_token}")
        res = Net::HTTP.get_response(uri)
        zammad_monitoring_stats = JSON.parse(res.body)
        number_of_users_currently_on_zammad = Sessions.list.uniq.count

        Rails.logger.info{"
            Delayed::Job.count -> #{delayed_jobs_count}
            Delayed::Job.where('attempts != 0').pluck(:handler) -> #{delayed_jobs_failures}
            monitoring stat at #{uri}: #{zammad_monitoring_stats}
            number of users currently on Zammad: #{number_of_users_currently_on_zammad}"}

        # telegram nextcrmMonitoringBot
        telegram_monitoring_bot_token = "1917084272:AAEIWzy3NaRSZ3P8eluGrRDvCjTyN9LvIMw"
        chat_ids = [
            "-591733852" # nextcrmMonitoring group chat
        ]
        api = TelegramAPI.new(telegram_monitoring_bot_token)
        
        #updates=api.getUpdates({"timeout"=>30})
        # updates.each do |update|
        #     if update['message']
        #         usr = update['message']['chat']['username'] || "unknown"
        #         if usr
        #             puts "Received update from @#{usr} [#{update['message']['chat']['first_name']} #{update['message']['chat']['last_name']}], chat_id: #{update['message']['chat']['id']}"     
        #         end
        #     else puts update.inspect
        #     end
        # end
     
        if zammad_monitoring_stats and zammad_monitoring_stats["healthy"] == false
            puts zammad_monitoring_stats
            chat_ids.each do |id|
                api.sendMessage(
                    id,
                    "⚠ *Ambiente:* _#{Rails.env}_ - *Messaggio:* _#{zammad_monitoring_stats["message"]}_",
                    parse_mode: "Markdown"
                )
            end
        end

       

    end
end
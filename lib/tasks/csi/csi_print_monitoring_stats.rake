namespace :csi do
    task :print_monitoring_stats => :environment do
        # Rails.logger = Logger.new("#{Rails.root}/log/print_monitoring_stats.log", 3, 20*1048576)
        Rails.logger = Logger.new(STDOUT)
        Rails.logger.info "------------------------------------------------------------------"
        Rails.logger.info "Delayed::Job.count -> #{Delayed::Job.count}"
        Rails.logger.info "Delayed::Job.where('attempts != 0').pluck(:handler) -> #{Delayed::Job.where('attempts != 0').pluck(:handler).map{|a| YAML.load(a).to_json}}"
        
        token = Setting.get('monitoring_token')

        uri = URI("http://localhost:3000/api/v1/monitoring/health_check?token=#{token}")
        res = Net::HTTP.get_response(uri)
        Rails.logger.info "monitoring stat at #{uri}: #{res.body}"
    end
end
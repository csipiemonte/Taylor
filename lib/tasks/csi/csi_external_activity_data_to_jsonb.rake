namespace :csi do
  desc "Copia i dati presenti nel campo data (text) di external_activities nel campo value (jsonb).\nArgs:\n - Scope (archived|open|all)"
  task :external_activities_data_to_json_data, [:scope] => :environment do |t, args|
    batch_size = 1000
    where_condition = { json_data: nil }
    if args[:scope] == 'archived'
      where_condition['archived'] = true
    elsif args[:scope] == 'open'
      where_condition['archived'] = false
    elsif args[:scope] == 'all'
    else
      puts "wrong value for argument 'Scope' (archived|open|all)"
      exit
    end

    to_process = ExternalActivity.where(where_condition).count
    puts "Begin processing [#{args[:scope]}] external activities, will process #{} external activities"

    start_time = batch_time = Time.now
    ExternalActivity.where(where_condition).find_each(:batch_size => batch_size).with_index do |activity, batch|
      activity.json_data = activity.data
      activity.save!

      if batch % batch_size == 0
        puts "batch done in #{batch_time - Time.now} |  [#{batch}/#{to_process}]"
        batch_time = Time.now
      end
    end
    puts "Elapsed time: #{(start_time - Time.now).to_i} seconds"
  end
end

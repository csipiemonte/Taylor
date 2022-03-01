namespace :features do
  desc "TODO"
  task update: :environment do
    Feature.update_from_configuration
  end

end

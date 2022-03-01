
class Feature < ApplicationModel

  def self.update_from_configuration
    nexcrm_instance = ENV["NEXTCRM_CLIENTE"]
    raise "variabile ambiente NEXTCRM_CLIENTE non trovata" unless nexcrm_instance
    environment = Rails.env 

    feature_config = HashWithIndifferentAccess.new(YAML.load(File.read(File.expand_path("../../../config/features/#{nexcrm_instance}.yml", __FILE__))))
  
    raise "environment '#{environment}'  non trovato nel file di configurazione '#{nexcrm_instance}.yml' " unless feature_config[environment]
    features = feature_config[environment][:features]
    features_list = features.map{|k,v| v }
    save_from_list features_list
  end
 
  def self.save_from_list(features)
    features.each do |feature|
      puts feature
      existing_feature = Feature.find_by(name: feature["name"])
      if existing_feature 
        existing_feature.update(feature)
      else
        Feature.create(feature)
      end
      
    end
  end
end

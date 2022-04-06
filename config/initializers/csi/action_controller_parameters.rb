# estensione per ottenere i parameters di una request filtrati secondo la config "filter_parameters"
# questo filtro si applica automaticamente nei log automatici di rails, per nascondere alcuni campi nei log (password, files, etc)
# questa estensione permette di applicare i filtri manualmente ai params, per loggarli custom 
# https://stackoverflow.com/questions/6152388/manually-filter-parameters-in-rails
# https://gist.github.com/hopsoft/79692dcfc7e5a8f82455b85a743f05c1

module ActionControllerParameters
    def filtered
      filter_hash self.to_unsafe_hash
    end
  
    private
  
    def filterer
      @filterer ||= ActionDispatch::Http::ParameterFilter.new(Rails.application.config.filter_parameters)
    end
  
    def filter_array(array)
      array.map do |item|
        case item
        when Array then filter_array(item)
        when Hash then filter_hash(item)
        else item
        end
      end
    end
  
    def filter_hash(hash)
      hash.each do |key, value|
        case value
        when Array then hash[key] = filter_array(value)
        when Hash then hash[key] = filter_hash(value)
        end
      end
      filterer.filter hash
    end
  end
  
  ::ActionController::Parameters.send :include, ::ActionControllerParameters
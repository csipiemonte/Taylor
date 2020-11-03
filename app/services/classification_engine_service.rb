class ClassificationEngineService

  BASE_PATH = "http://int-sdnet-convplat1.sdp.csi.it:7800"
  BASE_HEADERS = {
    'accept': 'application/json'
  }


  def self.classify(text, threshold=0.9)
    payload = {"text":text, "threshold":threshold}
    return self.post(BASE_PATH+"/predict",payload)
  end

  private

  def self.get(path, parameters={} )
    Rails.logger.info{"performing GET request to: #{path}"}
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    BASE_HEADERS.each do |key, value|
      request[key] = value
    end
    response = http.request(request)
    case response
      when Net::HTTPNoContent
        # 204 ->  ticketId non trovato
        Rails.logger.info{"No Content"}
        return nil
      when Net::HTTPSuccess, Net::HTTPRedirection
        # 2XX , 3XX OK
        Rails.logger.info{"GET request to: #{path} Success"}
        data = JSON.parse(response.body)
        return data
      when Net::HTTPClientError
        # 4XX
        data = Hash.from_xml response.body
        Rails.logger.error{"Error #{data['fault']['code']}: #{data['fault']['description']}"}
      else
        # 5XX
        #response.value
        Rails.logger.error{"Error #{data['fault']['code']}: #{response.body}"}
        return response.body
    end

  end

  def self.post(path, payload, parameters={})
    json_payload = payload.to_json
    Rails.logger.info{"performing POST request to: #{path}"}
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    BASE_HEADERS.each do |key, value|
      request[key] = value
    end
	  request.content_type = "application/json"
    request.body = json_payload

    response = http.request(request)
    case response
      when Net::HTTPSuccess, Net::HTTPRedirection
      Rails.logger.info{"POST request to: #{path} Success"}
        data = JSON.parse(response.body)
        return data
      else
        Rails.logger.error{"Error #{response.code} - #{response.body}" }
        return response.body
    end

  end


end

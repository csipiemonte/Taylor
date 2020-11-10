class ChatbotService

  BASE_PATH = "https://zammadbotrasa.demorpa.nivolapiemonte.it/webhooks/rest"
  BASE_HEADERS = {
    'accept': 'application/json'
  }


  def self.answerTo(text, user="")
    payload = {"sender":user, "text":text}
    return self.post(BASE_PATH+"/webhook",payload)
  end

  private

  def self.get(path, parameters={} )
    Rails.logger.info{"performing GET request to: #{path}"}
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.request_uri)
    BASE_HEADERS.each do |key, value|
      request[key] = value
    end
    response = http.request(request)
    case response
      when Net::HTTPNoContent
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
      else
        # 5XX
        #response.value
        return response.body
    end
  end

  def self.post(path, payload, parameters={})
    json_payload = payload.to_json
    Rails.logger.info{"performing POST request to: #{path}"}
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
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

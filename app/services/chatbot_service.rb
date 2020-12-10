class ChatbotService

  BASE_PATH = "https://zammadbotrasa.demorpa.nivolapiemonte.it/webhooks/rest"
  BASE_HEADERS = {
    'accept': 'application/json'
  }

  def self.bindSupervisors(chat_session)
    supervisors = []
    Chat::Agent.where('active = ? OR updated_at > ?', true, Time.zone.now - 8.hours).each do |item|
      user = User.lookup(id: item.updated_by_id)
      next if !user
      next if !(user.role?("Supervisor") || user.role?("Admin"))
      supervisors << user
    end
    client_list = Sessions.sessions
    supervisors.each do |supervisor|
      client_list.each do |client_id|
        session = Sessions.get(client_id)
        next if !session
        next if !session[:user]
        next if !session[:user]['id']
        next if session[:user]['id'].to_i != supervisor.id.to_i
        next if chat_session.preferences[:participants].include? client_id
        chat_session.preferences[:participants] = chat_session.add_recipient(client_id)
      end
    end
    chat_session.save
  end

  def self.answerTo(text, user="")
    payload = {"sender":user, "message":text}
    return self.post(BASE_PATH+"/webhook",payload)[0]["text"]
  end

  private

  def self.get(path, parameters={} )
    Rails.logger.info{"performing GET request to: #{path}"}
    uri = URI.parse(path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
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
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
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

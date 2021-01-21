class RemedyApiService

  vars = Setting.get('remedy_env_vars')
  ACCESS_TOKEN = vars['access_token']
  API_MANAGER_BASE_URL = vars['base_url']
  X_REQUEST_ID = vars['request_id']
  X_FORWARDED_FOR = vars['forwarded_for']



  BASE_HEADERS= {
    'Authorization': "Bearer #{ACCESS_TOKEN}",
    'X-Request-ID':  X_REQUEST_ID,  # campo libero, per auditing. il nome comparirà nel logger di remedy
    'X-Forwarded-For': X_FORWARDED_FOR, # campo libero, per auditing. il nome comparirà nel logger di remedy
    'accept': 'application/json'
  }


  def self.get_ticket_status(ticketId)
    path = "/tickets/#{ticketId}/stato"
    self.get(path)
  end

  def self.create_ticket(ticket)
    ## working example:
    # ticket = {
    #   "riepilogo": "prova da ruby",
    #   "dettaglio": "dettaglio prova da ruby",
    #   "impatto": "Vasto/Diffuso",
    #   "urgenza": "Critica",
    #   "tipologia": "Ripristino di servizio utente",
    #   "richiedente": {
    #   "personId": "PPL000000018476"
    #   },
    #   "categorizzazione": {
    #     "categoriaOperativa": {"livello1": "1L - Gestione PdL","livello2": "Fornitura/Configurazione","livello3": "PDL"}
    #   }
    # }

    # mi assicuro che tutte le key dell'hash siano stringhe (potrebbero essere symbols)
    ticket.deep_stringify_keys!

    if !ticket['riepilogo'] ||
      !ticket['dettaglio'] ||
      !ticket['impatto'] ||
      !ticket['urgenza'] ||
      !ticket['tipologia'] ||
      !ticket['richiedente'] ||
      !ticket['richiedente']['personId'] ||
      !ticket['categorizzazione'] ||
      !ticket['categorizzazione']['categoriaOperativa']
      Rails.logger.error{"Missing mandatory field in #{ticket}"}
      return false
    end
    impatto_enum = [ 'Vasto/Diffuso', 'Significativo/Grande', 'Moderato/Limitato', 'Minimo/Localizzato' ]
    if not impatto_enum.include?(ticket['impatto'])
      Rails.logger.error{"impatto must be one of #{impatto_enum}"}
      return false
    end
    urgenza_enum = [ 'Critica', 'Alta', 'Media', 'Bassa' ]
    if not urgenza_enum.include?(ticket['urgenza'])
      Rails.logger.error{"impatto must be one of #{urgenza_enum}"}
      return false
    end
    tipologia_enum = [ 'Ripristino di servizio utente', 'Ripristino di servizio infrastrutturale', 'Richiesta utente', 'Evento infrastrutturale' ]
    if not tipologia_enum.include?(ticket['tipologia'])
      Rails.logger.error{"impatto must be one of #{tipologia_enum}"}
      return false
    end

    path="/tickets"

    self.post(path, ticket)
  end


  ## funziona in test ma non in prod
  def self.get_tickets
    path = "/tickets"
    self.get(path)
  end

  private

  def self.get(path, parameters={} )
    endpoint = API_MANAGER_BASE_URL + path
    Rails.logger.info{"performing GET request to: #{endpoint}"}
    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
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
        Rails.logger.info{"GET request to: #{endpoint} Success"}
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
    endpoint = API_MANAGER_BASE_URL + path
    json_payload = payload.to_json
    Rails.logger.info{"performing POST request to: #{endpoint}"}
    uri = URI.parse(endpoint)
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
      Rails.logger.info{"POST request to: #{endpoint} Success"}
        data = JSON.parse(response.body)
        return data
      else
        Rails.logger.error{"Error #{response.code} - #{response.body}" }
        return response.body
    end

  end

  ##
  ## esempi con gemma RestClient invece di Net::Http
  ##
  def self.get_rest_client(path, parameters={} )
    response = RestClient.get API_MANAGER_BASE_URL + path,   BASE_HEADERS
    JSON.parse(response)[0]
  end

  def self.post_rest_client(path, payload, parameters={} )
    #response = RestClient.post API_MANAGER_BASE_URL + path, body,  BASE_HEADERS
    #JSON.parse(response)
    headers = BASE_HEADERS.merge({
      'Content-Type': 'application/json'
    })
    begin
      response = RestClient::Request.execute(
        method:  :post,
        url:     API_MANAGER_BASE_URL + path,
        headers: headers,
        payload: payload.to_json
      )
      return response.body
    rescue => e
      # This is the same as rescuing StandardError
      puts e.response
      Rails.logger.error e
    end

  end


end

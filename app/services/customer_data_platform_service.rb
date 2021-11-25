class CustomerDataPlatformService

  UNOMI_BASE_URL = 'https://ts-nextcrm-unomi-bo-api.preprod.nivolapiemonte.it'
  UNOMI_USERNAME = 'karaf'
  UNOMI_PASSWORD = 'karaf'

  BASE_HEADERS= {
    'Authorization': 'Basic '+Base64.encode64("#{UNOMI_USERNAME}:#{UNOMI_PASSWORD}"),
    'Content-Type': 'application/json'
  }

  def self.fetch_profile(email)
    path = '/cxs/profiles/search'
    body = { 
      text: email, 
      offset: 0,
      limit: 10,
      sortby: 'properties.lastName:asc,properties.firstName:desc', 
      condition: {
        type: 'booleanCondition', 
        parameterValues: {
          operator: 'and', 
          subConditions: [
            {
              type: 'profilePropertyCondition', 
              parameterValues: {
                propertyName: 'properties.firstName', 
                comparisonOperator: 'exists'
              }
            },
            {
              type: 'profilePropertyCondition', 
              parameterValues: {
                propertyName: 'properties.lastName', 
                comparisonOperator: 'exists'
              }
            }
          ]
        }
      }
     }
    url = "#{UNOMI_BASE_URL}#{path}"
    response = Faraday.post(url, body.to_json, BASE_HEADERS)
    
    if response.success?
      response_body = response.body
      result = Oj.load(response_body)
      result['list'][0]
    else
      # TODO,
      {error: '500'}
    end
    
  rescue StandardError => e
    Rails.logger.error e  
    raise e
  end

  def self.search_events(profile_id, limit = 200)
    path = '/cxs/events/search'
    body = { 
      offset: 0,
      limit: limit,
      condition: {
        type: 'eventPropertyCondition', 
        parameterValues: {
          propertyName: 'profileId', 
          comparisonOperator: 'equals', 
          propertyValue: '9a404711-9632-4886-9f38-7c0edfc73b39'
        }
      }
    }
    json_body = body.to_json
    url = "#{UNOMI_BASE_URL}#{path}"
    response = Faraday.post(url, json_body, BASE_HEADERS)
    
    if response.success?
      response_body = response.body
      result = Oj.load(response_body)
      #result['list'].select{|e|['Sanità','Tassa Auto'].include?(e['scope'])}
    else
      # TODO,
      {error: '500', message: response.body}
    end

  rescue StandardError => e
    Rails.logger.error e  
    raise e
  end
end
module Api::Nextcrm::V1::Concerns::ResponseHideAttributes
  extend ActiveSupport::Concern


  


  # work on array of articles
  def hideInternalArticles
    # optimized json parse
    obj_resp = Oj.load(response.body)
    if obj_resp.is_a? Array
      # override response array of articles with a selection of internal only articles 
      obj_resp = obj_resp.select { |article| article['internal'] == false }
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    end
  end

end
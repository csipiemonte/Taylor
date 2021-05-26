class Api::Nextcrm::V1::TicketArticlesController < ::TicketArticlesController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index_by_ticket
    super
    alterArticleAttributesInResponse()
  end

  def create
    params[:internal] = false # articles via api are always public
    if not params[:type_id]
      raise Exceptions::UnprocessableEntity, "Need at least article: { type_id: \"<id>\" "
    end
    super
    alterArticleAttributesInResponse()
  end

  # def update
  #   super
  # end

  # def destroy
  #   super
  # end

  private

  def  alterArticleAttributesInResponse
    # optimized json parse
    obj_resp = Oj.load(response.body)

    # array of articles, response of index_by_ticket
    if obj_resp.is_a? Array
      # override response array of articles with a selection of internal only articles 
      obj_resp = obj_resp.select { |article| article['internal'] == false }
      obj_resp.each do |article|
        hideInternalArticleAttributes(article)
      end
    # single article object, response of create
    else
      hideInternalArticleAttributes(obj_resp)
    end

    str_resp = Oj.dump(obj_resp)
    response.body = str_resp


  end

  def hideInternalArticleAttributes(articleObj)
    whitelist_parameters = %w[
      id 
      ticket_id 
      type_id
      from 
      to
      cc 
      subject 
      reply_to 
      message_id 
      message_id_md5 
      in_reply_to 
      content_type  
      references 
      body 
      attachments
      created_at 
      updated_at 
    ].to_set

    # TODO  substitute/hide operator name in the field "from"
    #article_creator = User.find_by(email: articleObj["created_by"])

    articleObj.keys.each do |attribute|
      articleObj.delete(attribute) unless whitelist_parameters.include?(attribute)
    end
    

  end


end
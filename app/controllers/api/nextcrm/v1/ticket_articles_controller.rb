class Api::Nextcrm::V1::TicketArticlesController < ::TicketArticlesController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index_by_ticket
    super
    hideInternalArticles()
  end

  def create
    if not params[:type_id]
      raise Exceptions::UnprocessableEntity, "Need at least article: { type_id: \"<id>\" "
    end
    super
  end

  def update
    super
  end

  def destroy
    super
  end

  private

  def  alterArticleAttributesInResponse
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
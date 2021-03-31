class Api::Nextcrm::V1::TicketArticlesController < ::TicketArticlesController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::ResponseHideAttributes

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


end
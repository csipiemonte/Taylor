class Api::Nextcrm::V1::GroupsController < ::GroupsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::CustomApiLogger

  def index
    super
  end

end
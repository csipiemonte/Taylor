class Api::Nextcrm::V1::GroupsController < ::GroupsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index
    super
  end

end
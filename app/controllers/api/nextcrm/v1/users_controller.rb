class Api::Nextcrm::V1::UsersController < ::UsersController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index
    
    super
    # puts response.body = {debug: "message"}.to_json
  end

  def create
    
    super
    
  end

end
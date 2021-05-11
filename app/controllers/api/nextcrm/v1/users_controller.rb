class Api::Nextcrm::V1::UsersController < ::UsersController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::Filterable

  def index
    
    super
    # puts response.body = {debug: "message"}.to_json
  end

  def search
    customer_role_id = Role.find_by(name: "Customer").id
    if params[:filter]
      filter = JSON.parse(params[:filter])
      query = filterToElasticSearchQuery(filter)
      params[:query] = query
    end
    if  params[:query] 
      params[:query] += " AND role_ids:#{customer_role_id} "
    else
      params[:query] = "role_ids:#{customer_role_id}"
    end
  
    super
  end

  def create
    # check if input email is present as linked account 
    if params[:email]
      value = params[:email]
      linked_authorization = Authorization.where(email: value).last
      if linked_authorization
        user = User.where(id: linked_authorization.user_id).last
        if user and user.email
          value = user.email
        end
      end
      params[:email] = value
    end
    super
  end

  def update
    super
  end

end
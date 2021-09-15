class Api::Nextcrm::V1::UsersController < ::UsersController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::Filterable
  include Api::Nextcrm::V1::Concerns::CustomApiLogger

  def index
    
    super
    alterUserAttributesInResponse()
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
    alterUserAttributesInResponse()
  end

  def create
    params[:active] = true
    # check if input email is present as linked account 
    if !params[:email] || params[:email].empty?
      raise Exceptions::UnprocessableEntity, "email is required"
    end
    
    value = params[:email]
    linked_authorization = Authorization.where(email: value).last
    if linked_authorization
      user = User.where(id: linked_authorization.user_id).last
      if user and user.email
        value = user.email
      end
    end
    params[:email] = value
    
    super
    alterUserAttributesInResponse()
  end

  def update
    if params[:id]
      user_to_update = User.where(id: params[:id]).take
      if user_to_update && !user_to_update.role?('Customer')
        raise Exceptions::NotAuthorized, "id must be of Customer user"
      end
    end
    if params[:email]
      user_to_update = User.where(email: params[:email]).take
      if user_to_update && !user_to_update.role?('Customer')
        raise Exceptions::NotAuthorized, "email must be of Customer user"
      end
    end
    params.delete :active
    super
    alterUserAttributesInResponse()
  end

  private

  def alterUserAttributesInResponse


    # optimized json parse
    obj_resp = Oj.load(response.body)

    if obj_resp.is_a? Array
      # loop over response array of object to hide/change attributes
      obj_resp.each do |user| 
        alterUserdata(user)
      end
    else
      user = obj_resp
      alterUserdata(user)
    end

    str_resp = Oj.dump(obj_resp)
    response.body = str_resp
  end

  def alterUserdata(user)
    # convert array in Set to improve 'include?' lookup speed in loop
    whitelist_parameters = %w[
      id 
      email
      firstname
      lastname
      phone
      fax
      mobile
      active
      note
      codice_fiscale
      tessera_team
      tessera_stp
      tessera_eni
      birthdate
      last_login
      created_at
      updated_at
    ].to_set

    # whitelist
    user.keys.each do |attribute|
      user.delete(attribute) unless whitelist_parameters.include?(attribute)
    end
  end

end
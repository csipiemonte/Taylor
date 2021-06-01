module Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  extend ActiveSupport::Concern

  included do
    prepend_before_action :check_apiman_jwt
  end



  def check_apiman_jwt
    logger.debug " api apimanager jwt ---->  #{request.headers["X-JWT-Assertion"]} "

    # return if params[:debug]

    apimanager_raw_jwt = request.headers["X-JWT-Assertion"]

    
    # test_payload = { 
    #   'http://wso2.org/claims/organization' => 'poc_nextCRM_team', 
    #   'http://wso2.org/claims/role' => ['Internal/subscriber', 'Application/marco.lucchesi_poc_NextCRM_PRODUCTION', 'Internal/everyone'], 
    #   'http://wso2.org/claims/applicationtier' => 'Unlimited', 
    #   'http://wso2.org/claims/keytype' => 'PRODUCTION', 
    #   'http://wso2.org/claims/version' => 'v1', 'iss' => 'wso2.org/products/am', 
    #   'http://wso2.org/claims/applicationname' => 'poc_NextCRM', 
    #   'http://wso2.org/claims/enduser' => 'marco.lucchesi@carbon.super', 
    #   'http://wso2.org/claims/enduserTenantId' => '-1234', 'http://wso2.org/claims/company' => 'CSI', 
    #   'http://wso2.org/claims/givenname' => 'Marco', 
    #   'http://wso2.org/claims/applicationUUId' => '8f1662b1-767c-45d8-a250-5f05517eb93e', 
    #   'http://wso2.org/claims/institution' => 'CSI', 
    #   'http://wso2.org/claims/subscriber' => 'marco.lucchesi', 
    #   'http://wso2.org/claims/tier' => 'Unlimited', 
    #   'http://wso2.org/claims/emailaddress' => 'marco.lucchesi@consulenti.csi.it', 
    #   'http://wso2.org/claims/lastname' => 'Lucchesi', 'exp' => 1_615_493_320, 
    #   'http://wso2.org/claims/applicationid' => '74', 'http://wso2.org/claims/usertype' => 'APPLICATION', 
    #   'http://wso2.org/claims/apicontext' => '/tecno/nextcrm/v1' 
    # }
    # apimanager_raw_jwt = JWT.encode test_payload, nil, 'none', { typ: 'JWT' }
    ###


    decoded_jwt = JWT.decode(apimanager_raw_jwt, nil, false)
    jwt_meta = decoded_jwt[0]
    application_name = jwt_meta["http://wso2.org/claims/applicationname"]
    if application_name
      application_name = application_name.downcase
    else
      raise Exceptions::NotAuthorized, "http://wso2.org/claims/applicationname in X-JWT-Assertion not found: #{apimanager_raw_jwt}"
    end

    app_user = User.find_by(email: "#{application_name}@csi.it")
    if app_user
      current_user_set(app_user, "basic_auth")
      logger.debug { "current user setted to #{current_user.email} " }
    else
      Rails.logger.error{"user not found with X-JWT-Assertion http://wso2.org/claims/applicationname: #{application_name}"}
      raise Exceptions::NotAuthorized, "user not found with X-JWT-Assertion: #{apimanager_raw_jwt}  -  http://wso2.org/claims/applicationname: #{application_name}"

    end

  end

end
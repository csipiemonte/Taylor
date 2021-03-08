module Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  extend ActiveSupport::Concern

  included do
    before_action :check_apiman_jwt
  end



  def check_apiman_jwt
    logger.debug " api apimanager jwt ---->  #{request.headers["X-JWT-Assertion"]} "
    apimanager_raw_jwt = request.headers["X-JWT-Assertion"]

    ## TODO eliminare finito lo sviluppo
    # test_payload = {
    #   "jti": "ad17c45b-5881-474a-adeb-dafd1573edea",
    #   "iat": 1614619919,
    #   "exp": 1614623519,
    #    "Subscriber": "John Doe",
    #    "ApplicationName":"sanita1",
    #    "ApiContext":"contesto",
    #    "Version":"1.0.0",
    #    "Tier":"prova"
    #  }
    # apimanager_raw_jwt = JWT.encode test_payload, nil, 'none', { typ: 'JWT' }
    ###


    decoded_jwt = JWT.decode(apimanager_raw_jwt, nil, false)
    jwt_meta = decoded_jwt[0]
    application_name = jwt_meta["ApplicationName"]
    app_user = User.find_by(email: "#{application_name}@csi.it")
    if app_user
      current_user_set(app_user, "basic_auth")
      logger.debug { "current user setted to #{current_user.email} " }
    else
      raise "user not found on X-JWT-Assertion"
    end

  end

end
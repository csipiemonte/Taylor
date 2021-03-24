class Controllers::RemedyControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('admin')
end

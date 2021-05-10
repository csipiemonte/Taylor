class Controllers::CategoriesControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('admin')
end

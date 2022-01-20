class Controllers::CategoriesControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!(['ticket.agent', 'admin'])
end

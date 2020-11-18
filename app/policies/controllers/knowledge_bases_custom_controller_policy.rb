class Controllers::KnowledgeBasesCustomControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('admin.group')
end

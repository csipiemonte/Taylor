class Controllers::VirtualAgentControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('admin')
end

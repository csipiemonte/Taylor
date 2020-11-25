class Controllers::ChatMonitorControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('chat.supervisor')
end

# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

class Controllers::ChatsMonitorControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('chat.supervisor')
end

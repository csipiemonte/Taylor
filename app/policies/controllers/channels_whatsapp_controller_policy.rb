class Controllers::ChannelsWhatsappControllerPolicy < Controllers::ApplicationControllerPolicy
  default_permit!('admin.channel_whatsapp')
end

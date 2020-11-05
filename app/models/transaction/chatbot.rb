class Transaction::Chatbot

  def initialize(item, params = {})
    @item = item
    @params = params
  end

  def perform
    return if Setting.get('import_mode')
    return if @item[:object] != 'Chat Message'
    Rails.logger.info "HERE WE AREEEEEEEEEE"
    message = Chat::Message.find_by(id: @item[:object_id])
    created_by = message[:created_by_id]
    Rails.logger.info "INSIDE IF"
    chat_session = Chat::Session.find_by(id: message[:chat_session_id])
    Rails.logger.info "SESSION ID: #{chat_session}"
    Rails.logger.info message
    chat_message = Chat::Message.create(
      chat_session_id: message[:chat_session_id],
      content:         "risposta del bot a \"#{message[:content]}\"",
      created_by_id:   1,
    )
    message_to_send = {
      event: 'chat_session_message',
      data:  {
        session_id: message[:chat_session_id],
        message:    chat_message
      },
    }

    # send to participents
    @item[:clients].each do |client_id,client|
      Rails.logger.info "sending message to: #{client_id}"
      Sessions.send(client_id,message_to_send)
    end

  end


end

class Transaction::Chatbot

  def initialize(item, params = {})
    @item = item
    @params = params
  end

  def perform
    return if Setting.get('import_mode')
    if @item[:object] == 'Chat Session'
      chatbot = User.find_by(login: 'chatbot@zammad.org')
      chat_session = @item[:chat_session]
      client_id = 333
      clients = [@item[:client_id],client_id]
      params = {
        session: {
          "id" => chatbot.id
        },
        payload: {
          "agent" => chatbot,
          "chat_id" => chat_session.chat_id
        },
        client_id: client_id,
        clients: clients
      }
      event = Sessions::Event::ChatSessionStart.new(params)
      result = event.run
      event.destroy
    elsif @item[:object] == 'Chat Message'
      chatbot = User.find_by(login: 'chatbot@zammad.org')
      message = Chat::Message.find_by(id: @item[:object_id])
      created_by = message[:created_by_id]
      chat_session = Chat::Session.find_by(id: message[:chat_session_id])
      #reply = ChatbotService.answerTo(message)[0]["text"]
      reply = "risposta del chatbot a \"#{message.content}\""
      chat_message = Chat::Message.create(
        chat_session_id: message[:chat_session_id],
        content:         reply,
        created_by_id:   chatbot.id,
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
        Sessions.send(client_id,message_to_send)
      end
      chat_ids = Chat.agent_active_chat_ids(chatbot)
      # broadcast new state to agents
      Chat.broadcast_agent_state_update(chat_ids)
    end
  end

end

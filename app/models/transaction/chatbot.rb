class Transaction::Chatbot

  def initialize(item, params = {})
    @item = item
    @params = params
    @chatbot = User.find_by(login: 'chatbot@zammad.org')
  end

  def perform
    if @item[:object] == 'Chat Session'
      ChatbotService.bindSupervisors(@item[:chat_session])
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')
      client_id = '0000000' #FAKE CLIENT_ID FOR CHATBOT
      clients = [@item[:client_id],client_id]
      params = {
        session: {
          "id" => @chatbot.id
        },
        payload: {
          "agent" => @chatbot,
          "chat_id" => @item[:chat_session].chat_id
        },
        client_id: client_id,
        clients: clients
      }
      event = Sessions::Event::ChatSessionStart.new(params)
      result = event.run
      event.destroy
      welcome_text = ChatbotService.answerTo("/get_started")
      welcome_message = createMessageFromText(welcome_text,@chatbot.id,@item[:chat_session].id)
      sendMessageToClient(welcome_message,@item[:chat_session].id,clients)

    elsif @item[:object] == 'Chat Message'
      ChatbotService.bindSupervisors(@item[:chat_session])
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')
      message = Chat::Message.find_by(id: @item[:object_id])
      chat_session = Chat::Session.find_by(id: message[:chat_session_id])
      if !chat_session.stop_chatbot
        created_by = message[:created_by_id]
        reply_text = ChatbotService.answerTo(message.content)
        if(reply_text['@handoff'])
          performHandoff(chat_session)
        else
          reply_message = createMessageFromText(reply_text,@chatbot.id,message[:chat_session_id])
          sendMessageToClient(reply_message,message[:chat_session_id])
        end
      end
    end
  end

  private

  def performHandoff(chat_session)
    chat_session.stop_chatbot = true
    chat_session.save!
    params = {
      session: {
        "id" => @chatbot.id
      },
      payload: {
        "session_id" => chat_session.id,
        "chat_id" => chat_session.chat_id
        },
      clients: @item[:clients]
      }
    event = Sessions::Event::ChatbotTransfer.new(params)
    result = event.run
    event.destroy
  end

  def createMessageFromText(text,user_id,session_id)
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         text,
      created_by_id:   user_id,
    )
    message = {
      event: 'chat_session_message',
      data:  {
        session_id: @item[:chat_session].session_id,
        message:    chat_message
      },
    }
  end

  def sendMessageToClient(message_to_send,session_id,clients=nil)
    clients = clients ? clients : @item[:clients]
    # send to participents
    clients.each do |client_id,client|
      Sessions.send(client_id,message_to_send)
    end
    chat_ids = Chat.agent_active_chat_ids(@chatbot)
    # broadcast new state to agents
    Chat.broadcast_agent_state_update(chat_ids)
  end

end

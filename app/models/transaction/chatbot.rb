class Transaction::Chatbot
  #transazione tra client e websocket
  def initialize(item, params = {})
    @item = item
    @params = params
    @chatbot = User.find_by(login: 'chatbot@zammad.org')
    #primo step alla apertura della chat
  end

  def perform
    if @item[:object] == 'Chat Session'
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')
      client_id = 0 #FAKE CLIENT_ID FOR CHATBOT
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
      # invocazione dell'event get_started per avere saluti iniziali
      welcome_text = ChatbotService.answerTo("/get_started") 
      # /get_started è un INTENT corrisponde al benvenuto
      # simuliamo un benvenuto con 'Ciao come stai?' che innesca il /get_started
      # se non è una stringa di tipo INTENT lo interpreta come domanda
      welcome_message = createMessageFromText(welcome_text,@chatbot.id,@item[:chat_session].id)
      sendMessageToClient(welcome_message,@item[:chat_session].id,clients)

    elsif @item[:object] == 'Chat Message'
      ChatbotService.bindSupervisors(@item[:chat_session])
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')
      message = Chat::Message.find_by(id: @item[:object_id])
      chat_session = Chat::Session.find_by(id: message[:chat_session_id])
      actual_chat = Chat.find_by(id: chat_session.chat_id)
      active_agent_count = actual_chat.get_active_agent_count  # contiamo gli agenti disponibili
      Rails.logger.info "active_agent_count #{active_agent_count}"
      if !chat_session.stop_chatbot
        created_by = message[:created_by_id]
        reply_text = ChatbotService.answerTo(message.content)
        # stiamo usando Zimmy, se il content è 'vorrei parlare con un operatore' o simili
        # restistuisce un json con chiave '@handoff' e passa la palla ad un operatore reale
        if((!reply_text || reply_text['@handoff']) && active_agent_count > 0)
          performHandoff(chat_session)
        else
          Rails.logger.info "reply_text #{reply_text}"
          reply_message = createMessageFromText(reply_text,@chatbot.id,message[:chat_session_id])
          sendMessageToClient(reply_message,message[:chat_session_id])
        end
      end
    end
  end

  private

  def performHandoff(chat_session)
    # chat_session.stop_chatbot se è TRUE il chatbot è fermo e si usa l'operatore umano
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

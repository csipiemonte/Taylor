class Transaction::Chatbot
  def initialize(item, params = {})
    @item = item
    @params = params
    @chatbot = User.find_by(login: 'chatbot@zammad.org')
  end

  def perform
    if @item[:object] == 'Chat Session'
      # Avviene in fase di inizializzazione della chat, cfr lib/sessions/event/chat_session_init.rb
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')

      client_id = 0 # FAKE CLIENT_ID FOR CHATBOT
      clients = [@item[:client_id], client_id]
      params = {
        session:   {
          'id' => @chatbot.id
        },
        payload:   {
          'agent'   => @chatbot,
          'chat_id' => @item[:chat_session].chat_id
        },
        client_id: client_id,
        clients:   clients
      }
      event = Sessions::Event::ChatSessionStart.new(params)
      event.run
      event.destroy

      # invocazione dell'intent 'get_started' dal motore di AI; il richiamo esplicito
      # di un intent si ottiene premettendo il carattere '/' al nome dell'intent.
      # Per info sull'intent /get_started
      # cfr. https://gitlab.csi.it/prodotti/nextcrm/zammad/wikis/rif_channel_chat
      get_started_response = ChatbotService.answer_to('/get_started')
      Rails.logger.info "get_started_response #{get_started_response}"

      welcome_message = get_started_event_message(get_started_response, @chatbot.id, @item[:chat_session].id)
      send_message_to_client(welcome_message, clients)

    elsif @item[:object] == 'Chat Message'
      # Avviene durante lo scambio di messaggi nella chat, cfr lib/sessions/event/chat_session_message.rb
      ChatbotService.bind_supervisors(@item[:chat_session])
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')

      message = Chat::Message.find_by(id: @item[:object_id])
      chat_session = Chat::Session.find_by(id: message[:chat_session_id])
      actual_chat = Chat.find_by(id: chat_session.chat_id)
      active_agent_count = actual_chat.get_active_agent_count  # contiamo gli agenti disponibili
      Rails.logger.info "active_agent_count #{active_agent_count}"

      if !chat_session.stop_chatbot
        ai_response = ChatbotService.answer_to(message.content)
        Rails.logger.info "ai_response #{ai_response}"
        reply_text = ai_response[0]['text']

        # stiamo usando il chat, a fronte di una domanda tipo 'vorrei parlare con un operatore' o simili
        # il motore di AI riconosce l'intent 'umano' e restistuisce un json con chiave '@handoff',
        # che viene recepito dalla logica sottostante per passare la palla (handoff) ad un operatore reale.
        if (!reply_text || reply_text['@handoff']) && active_agent_count.positive?
          perform_handoff(chat_session)
        else
          Rails.logger.info "reply_text #{reply_text}"
          reply_message = create_message_from_text(reply_text, @chatbot.id, message[:chat_session_id])
          send_message_to_client(reply_message)
        end
      end
    end
  end

  private

  def perform_handoff(chat_session)
    # chat_session.stop_chatbot: se e' TRUE il chatbot e' fermo e si usa l'operatore umano
    chat_session.stop_chatbot = true
    chat_session.save!
    params = {
      session: {
        'id' => @chatbot.id
      },
      payload: {
        'session_id' => chat_session.id,
        'chat_id'    => chat_session.chat_id
      },
      clients: @item[:clients]
    }
    event = Sessions::Event::ChatbotTransfer.new(params)
    event.run
    event.destroy
  end

  # Metodo che crea un json di risposta da inviare al client della chat;
  # il json di risposta e' composto da:
  # - event: evento 'chat_get_started' che dovra' essere intercettato su chat.coffee
  # - data: dati associati all'evento
  # cfr. https://gitlab.csi.it/prodotti/nextcrm/zammad/wikis/rif_channel_chat
  def get_started_event_message(get_started_resp, user_id, session_id)
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         get_started_resp[0]['text'],
      created_by_id:   user_id,
    )
    {
      event: 'chat_get_started',
      data:  {
        session_id:     @item[:chat_session].session_id,
        message:        chat_message,
        intro_message:  get_started_resp[1]['text'],
        intent_buttons: get_started_resp[1]['buttons']
      },
    }
  end

  # Metodo che crea un json di risposta da inviare al client della chat;
  # il json di risposta e' composto da:
  # - event: evento 'chat_session_message' che dovra' essere intercettato su chat.coffee
  # - data: dati associati all'evento
  def create_message_from_text(text, user_id, session_id)
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         text,
      created_by_id:   user_id,
    )
    {
      event: 'chat_session_message',
      data:  {
        session_id: @item[:chat_session].session_id,
        message:    chat_message
      },
    }
  end

  # Metodo che invia il messaggio al client
  def send_message_to_client(message_to_send, clients = nil)
    chat_clients = clients ? clients : @item[:clients]
    # send to participents
    chat_clients.each_key do |client_id|
      Sessions.send(client_id, message_to_send)
    end
    chat_ids = Chat.agent_active_chat_ids(@chatbot)
    # broadcast new state to agents
    Chat.broadcast_agent_state_update(chat_ids)
  end
end

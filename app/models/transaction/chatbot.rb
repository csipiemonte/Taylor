class Transaction::Chatbot
  def initialize(item, params = {})
    @item = item
    @params = params
    @chatbot = User.find_by(login: 'chatbot@zammad.org')
    @api_host = Setting.get('chat_bot_api_settings')
  end

  def perform
    if @item[:object] == 'Chat Session'
      # Avviene in fase di inizializzazione della chat, cfr lib/sessions/event/chat_session_init.rb
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')

      perform_chat_session

    elsif @item[:object] == 'Chat Message'
      # Avviene durante lo scambio di messaggi nella chat, cfr lib/sessions/event/chat_session_message.rb
      ChatbotService.bind_supervisors(@item[:chat_session])
      return if Setting.get('import_mode') || !Setting.get('chatbot_status')

      perform_chat_message
    end
  end

  private

  def perform_chat_session
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
    get_started_response = call_chatbot_webhook('/get_started')
    if !get_started_response.success?
      Rails.logger.error "Errore occorso durante l'invocazione del chatbot (intent /get_started), dettaglio: #{get_started_response.error}"
      send_message_to_client(error_message(@chatbot.id, @item[:chat_session].id), clients)
      return
    end

    msg = chatbot_response_message(
      JSON.parse(get_started_response.body),
      @chatbot.id,
      @item[:chat_session].id
    )
    send_message_to_client(msg, clients)
  end

  def perform_chat_message
    message = Chat::Message.find_by(id: @item[:object_id])
    chat_session = Chat::Session.find_by(id: message[:chat_session_id])
    return if chat_session.stop_chatbot

    ai_response = call_chatbot_webhook(message.content)
    if !ai_response.success?
      Rails.logger.error "Errore occorso durante l'invocazione del chatbot, dettaglio: #{ai_response.error}"
      send_message_to_client(error_message(@chatbot.id, @item[:chat_session].id), clients)
      return
    end

    ai_response_body = JSON.parse(ai_response.body)
    Rails.logger.info "ai_response_body #{ai_response_body}"
    reply_text = ai_response_body[0]['text']
    actual_chat = Chat.find_by(id: chat_session.chat_id)

    # stiamo usando il chat, a fronte di una domanda tipo 'vorrei parlare con un operatore' o simili
    # il motore di AI riconosce l'intent 'umano' e restistuisce un json con chiave '@handoff',
    # che viene recepito dalla logica sottostante per passare la palla (handoff) ad un operatore reale.
    if reply_text['@handoff']
      if actual_chat.get_active_agent_count.positive?
        perform_handoff(chat_session)
      else
        reply_msg = chatbot_response_message([{ text: 'operatore umani non disponibili, riprova dopo' } ], @chatbot.id, message[:chat_session_id])
        send_message_to_client(reply_msg)
      end
      return
    end

    reply_msg = chatbot_response_message(ai_response_body, @chatbot.id, message[:chat_session_id])
    send_message_to_client(reply_msg)
  end

  # Metodo che esegue la chiamata POST al webhook del chatbot
  def call_chatbot_webhook(msg_text)
    chat = Chat.find_by(id: @item[:chat_session].chat_id)
    # recuperiamo l'id della chat specificato dal frontend nel index html
    # esempio su csp: $(function () { new ZammadChat({ fontSize: '12px', chatId: 1, debug: true }); })
    # chatId 1 recuperera dalla tabella con id 1 la colonna name ad esempio bolloauto
    # importante:  chat.name deve essere un argomento che corrisponde ad un chatbot utilizzabile, impostare da BO lo stesso nome della chat che si vuole usare
    chatbot_url = "#{@api_host}/#{chat.name}/webhook"
    Rails.logger.info "[call_chatbot_webhook] chatbot_url: #{chatbot_url}"
    UserAgent.post(
      chatbot_url,
      {
        'sender':  @item[:chat_session].id, # id del chat customer per poter eventualmente stabilire una conversazione
        'message': msg_text
      },
      { json: true }
    )
  end

  # Metodo incaricato di passare la chat dal chatbot automatizzato ad un operatore umano.
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
    Rails.logger.info "params@ #{params}"
    Rails.logger.info "chat_session@ #{chat_session}"
    event = Sessions::Event::ChatbotTransfer.new(params)
    event.run
    event.destroy
  end

  # Metodo che crea un messaggio di errore da mostrare in caso di problemi occorsi
  # durante la comunicazione con il chatbot
  def error_message(user_id, session_id)
    err_msg = 'A causa di un problema tecnico non &egrave; stato possibile recuperare la risposta. Ci scusiamo per il disservizio.'
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         err_msg,
      created_by_id:   user_id,
    )
    {
      event: 'chat_session_message',
      data:  {
        session_id: @item[:chat_session].session_id,
        message:    chat_message
      }
    }
  end

  # Metodo che crea un json di risposta da inviare al client della chat;
  # il json di risposta e' composto da:
  # - event: evento 'chat_session_message' che dovra' essere intercettato su chat.coffee
  # - data: dati associati all'evento
  # cfr. https://gitlab.csi.it/prodotti/nextcrm/zammad/wikis/rif_channel_chat
  def chatbot_response_message(chatbot_resp, user_id, session_id)
    Rails.logger.info "chatbot_resp #{chatbot_resp}"
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         'Risposta automatica del chatbot.',
      created_by_id:   user_id,
    )
    {
      event: 'chat_session_message',
      data:  {
        session_id:       @item[:chat_session].session_id,
        message:          chat_message,
        chatbot_response: chatbot_resp
      }
    }
  end

  # Metodo che invia il messaggio al client
  def send_message_to_client(message_to_send, clients = nil)
    chat_clients = @item[:clients]
    chat_clients = clients if clients
    # send to participents
    chat_clients.each do |client_id, _client|
      Sessions.send(client_id, message_to_send)
    end
    chat_ids = Chat.agent_active_chat_ids(@chatbot)
    Rails.logger.info "chat_ids #{chat_ids}"
    Rails.logger.info "chatbot #{@chatbot}"
    # broadcast new state to agents
    Chat.broadcast_agent_state_update(chat_ids)
  end
end

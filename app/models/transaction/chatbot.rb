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
      bind_supervisors(@item[:chat_session])
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
    get_started_response = UserAgent.post(
      "#{@api_host}/webhook",
      {
        'sender':  @item[:chat_session].id, # id del chat customer per poter eventualmente stabilire una conversazione
        'message': '/get_started'
      },
      { json: true }
    )
    Rails.logger.info "get_started_response #{get_started_response}"

    if !get_started_response.success?
      send_message_to_client(error_message(@chatbot.id, @item[:chat_session].id), clients)
      return
    end

    msg = get_started_message(get_started_response.body, @chatbot.id, @item[:chat_session].id)
    send_message_to_client(msg, clients)
  end

  def perform_chat_message
    message = Chat::Message.find_by(id: @item[:object_id])
    chat_session = Chat::Session.find_by(id: message[:chat_session_id])
    return if chat_session.stop_chatbot

    ai_response = UserAgent.post(
      "#{@api_host}/webhook",
      {
        'sender':  @item[:chat_session].id, # id del chat customer per poter eventualmente stabilire una conversazione
        'message': message.content
      },
      { json: true }
    )
    Rails.logger.info "ai_response #{ai_response}"

    if !ai_response.success?
      send_message_to_client(error_message(@chatbot.id, @item[:chat_session].id), clients)
      return
    end

    reply_text = ai_response.body[0]['text']
    actual_chat = Chat.find_by(id: chat_session.chat_id)
    active_agent_count = actual_chat.get_active_agent_count  # operatori disponibili

    # stiamo usando il chat, a fronte di una domanda tipo 'vorrei parlare con un operatore' o simili
    # il motore di AI riconosce l'intent 'umano' e restistuisce un json con chiave '@handoff',
    # che viene recepito dalla logica sottostante per passare la palla (handoff) ad un operatore reale.
    if reply_text['@handoff'] && active_agent_count.positive?
      perform_handoff(chat_session)
      return
    end

    reply_msg = chat_session_message(ai_response.body[0], @chatbot.id, message[:chat_session_id])
    send_message_to_client(reply_msg)
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
  def get_started_message(get_started_resp, user_id, session_id)
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         get_started_resp[0]['text'],
      created_by_id:   user_id,
    )
    {
      event: 'chat_session_message',
      data:  {
        session_id:     @item[:chat_session].session_id,
        message:        chat_message,
        intro_message:  get_started_resp[1]['text'],
        intent_buttons: get_started_resp[1]['buttons']
      }
    }
  end

  # Metodo che crea un json di risposta da inviare al client della chat;
  # il json di risposta e' composto da:
  # - event: evento 'chat_session_message' che dovra' essere intercettato su chat.coffee
  # - data: dati associati all'evento
  def chat_session_message(elem_0_resp, user_id, session_id)
    chat_message = Chat::Message.create(
      chat_session_id: session_id,
      content:         elem_0_resp['text'],
      created_by_id:   user_id,
    )
    {
      event: 'chat_session_message',
      data:  {
        session_id:     @item[:chat_session].session_id,
        message:        chat_message,
        intent_buttons: get_started_resp[0]['buttons'] # eventuali btn di intent
      }
    }
  end

  # Metodo che invia il messaggio al client
  def send_message_to_client(message_to_send, clients = nil)
    chat_clients = clients ? clients : @item[:clients]
    # send to participents
    chat_clients.each do |client_id, _client|
      Sessions.send(client_id, message_to_send)
    end
    chat_ids = Chat.agent_active_chat_ids(@chatbot)
    # broadcast new state to agents
    Chat.broadcast_agent_state_update(chat_ids)
  end

  def bind_supervisors(chat_session)
    supervisors = []
    Chat::Agent.where('active = ? OR updated_at > ?', true, Time.zone.now - 8.hours).each do |item|
      user = User.lookup(id: item.updated_by_id)
      next if !user
      next if !(user.role?('Supervisor') || user.role?('Admin'))

      supervisors << user
    end
    client_list = Sessions.sessions
    supervisors.each do |supervisor|
      client_list.each do |client_id|
        session = Sessions.get(client_id)
        next if !session
        next if !session[:user]
        next if !session[:user]['id']
        next if session[:user]['id'].to_i != supervisor.id.to_i
        next if chat_session.preferences[:participants].include? client_id

        chat_session.preferences[:participants] = chat_session.add_recipient(client_id)
      end
    end
    chat_session.save
  end
end

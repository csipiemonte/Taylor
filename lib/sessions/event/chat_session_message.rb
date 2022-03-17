# Copyright (C) 2012-2022 Zammad Foundation, https://zammad-foundation.org/

class Sessions::Event::ChatSessionMessage < Sessions::Event::ChatBase

=begin

a agent or customer creates a new chat session message

payload

  {
    event: 'chat_session_message',
    data: {
      content: 'some message',
    },
  }

return is sent as message back to peer

=end

  def run
    return super if super
    return if !check_chat_session_exists

    chat_session = current_chat_session

    user_id = nil
    if @session
      user_id = @session['id']
    end

    sneak_peek = @payload['data']['sneak_peek'] ? @payload['data']['sneak_peek'] : false
    whispering = @payload['data']['whispering'] ? @payload['data']['whispering'] : false
    chat_message = {}

    if sneak_peek
      chat_message = {
        chat_session_id: chat_session.id,
        content:         @payload['data']['content'],
        created_by_id:   user_id,
        sneak_peek:      true,
        whispering:      whispering
      }
    else
      chat_message = Chat::Message.create(
        chat_session_id: chat_session.id,
        content:         @payload['data']['content'],
        created_by_id:   user_id,
        whispering:      whispering
      )
    end

    customers = []

    if whispering || sneak_peek
      customers = find_customers chat_session.preferences[:participants]
      chat_session.preferences[:participants] -= customers
      chat_session.save
    end

    message = {
      event: 'chat_session_message',
      data:  {
        session_id: chat_session.session_id,
        message:    chat_message,
      },
    }

    if !(whispering || sneak_peek)
      # Transazione invocata solo se il chatbot e' attivo
      TransactionJob.perform_now(
        object:       'Chat Message',
        type:         'chat_message',
        user_id:      user_id,
        chat_session: chat_session,
        object_id:    chat_message.id,
        cli_id:       @client_id,
        clients:      @clients,
        event:        message
      )
    end

    # send to participents
    chat_session.send_to_recipients(message, @client_id)

    chat_session.preferences[:participants] += customers
    chat_session.save

    # send chat_session_init to agent
    {
      event: 'chat_session_message',
      data:  {
        session_id:   chat_session.session_id,
        message:      chat_message,
        self_written: true,
      },
    }

  end

  def find_customers(participants)
    customers = []
    participants.each do |client_id|
      session = Sessions.get(client_id)
      if session && session[:user] && session[:user]['id']
        user = User.find_by(id: session[:user]['id'].to_i)
        next if user && !user.role?('Customer')
      end
      customers << client_id
    end
    customers
  end

end

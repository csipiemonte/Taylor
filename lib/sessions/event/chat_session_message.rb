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
    chat_message = Chat::Message.create(
      chat_session_id: chat_session.id,
      content:         @payload['data']['content'],
      created_by_id:   user_id,
    )

    whispering = @payload['data']['whispering']
    customers = []

    if whispering
      chat_message.whispering = true
      chat_message.save!
      customers = findCustomers chat_session.preferences[:participants]
      Rails.logger.info "customers: #{customers}"
      Rails.logger.info "participants: #{chat_session.preferences[:participants]}"
      chat_session.preferences[:participants] -= customers
      chat_session.save
      Rails.logger.info "after save: #{chat_session.preferences[:participants]}"
    end

    message = {
      event: 'chat_session_message',
      data:  {
        session_id: chat_session.session_id,
        message:    chat_message,
      },
    }

    if !@payload['data']['whispering']
      Transaction::BackgroundJob.run(
          object:     'Chat Message',
          type:       'chat_message',
          user_id:  user_id,
          chat_session: chat_session,
          object_id: chat_message.id,
          cli_id: @client_id,
          clients: @clients,
          event: message
      )
    end

    # send to participents
    chat_session.send_to_recipients(message, @client_id)

    chat_session.preferences[:participants] += customers
    chat_session.save
    Rails.logger.info "after second save: #{chat_session.preferences[:participants]}"

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

  def findCustomers(participants)
    customers = []
    participants.each do |client_id|
      session = Sessions.get(client_id)
      if session && session[:user] && session[:user]['id']
        user = User.find_by(id: session[:user]['id'].to_i)
        next if user && !user.role?("Customer")
      end
      customers << client_id
    end
    customers
  end

end

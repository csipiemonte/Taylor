class Sessions::Event::ChatSessionFlag < Sessions::Event::ChatBase

=begin

a agent start`s a new chat session

payload

  {
    event: 'chat_session_start',
    data: {},
  }

return is sent as message back to peer

=end

  def run
    return super if super
    return if !permission_check('chat.agent', 'chat')


    chat_session = Chat::Session.find_by(session_id: @payload['session_id'])
    if !chat_session
      return {
        event: 'chat_session_flag',
        data:  {
          state:   'failed',
          message: 'No session available.',
        },
      }
    end

    #updating flag on db
    ChatbotService.bindSupervisors(chat_session)
    chat_session.flag_raised = @payload['state']
    chat_session.save


    user = chat_session.agent_user
    data = {
      event: 'chat_session_flag',
      data:  {
        state:      chat_session.flag_raised,
        agent:      user,
        session_id: chat_session.session_id,
        chat_id:    chat_session.chat_id,
      },
    }
    chat_session.send_to_recipients(data)

    nil
  end

end

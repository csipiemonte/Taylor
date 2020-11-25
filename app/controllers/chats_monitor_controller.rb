# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ChatMonitorController < ApplicationController
  prepend_before_action { authentication_check && authorize! }

  def index
    chat_sessions = Chat::Session.all
    chat_sessions.each do |chat_session|
      agent = Users.find_by(id: chat_session['user_id'])
      chat_session[:agent] = agent[:firstname]+' '+agent[:lastname]
      messages = Chat::Messages.where(chat_session_id:chat_session['id'])
      chat_session[:messages] = messages
    end
    render json: chat_sessions
  end

end

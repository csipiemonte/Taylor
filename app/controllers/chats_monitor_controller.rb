# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ChatMonitorController < ApplicationController
  prepend_before_action { authentication_check && authorize! }

  def index
    sessions = []
    Chat::Session.all.each do |chat_session|
      session = chat_session.as_json
      if session && chat_session['user_id']
        agent = User.find_by(id: chat_session['user_id'])
        session[:agent] = agent[:firstname]+' '+agent[:lastname]
        sessions << session
      end
    end
    render json: sessions
  end

  def show
    messages = Chat::Message.where(chat_session_id:params[:chat_session_id])
    render json: messages
  end

end

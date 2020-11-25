# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ChatMonitorController < ApplicationController
  prepend_before_action { authentication_check && authorize! }

  def index
    sessions = []
    Chat::Session.all.each do |chat_session|
      session = chat_session.as_json
      Rails.logger.info "CHAT SESSION: #{session}"
      agent = User.find_by(id: chat_session['user_id'])
      session[:agent] = agent[:firstname]+' '+agent[:lastname]
      messages = Chat::Message.where(chat_session_id:chat_session['id'])
      session[:messages] = messages
      sessions << session
    end
    render json: sessions
  end

end

# Copyright (C) 2020-2022 CSI Piemonte, https://www.csipiemonte.it/

class ChatsMonitorController < ApplicationController
  prepend_before_action { authentication_check && authorize! }

  def index
    sessions = []
    Chat::Session.all.each do |chat_session|
      session = chat_session.as_json
      next if !session || !chat_session['user_id']

      agent = User.find_by(id: chat_session['user_id'])
      session[:agent] = "#{agent[:firstname]} #{agent[:lastname]}"
      sessions << session
    end
    render json: sessions
  end

  def show
    messages = Chat::Message.where(chat_session_id: params[:chat_session_id])
    render json: messages
  end
end

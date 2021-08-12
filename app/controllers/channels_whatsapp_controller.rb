# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ChannelsWhatsappController < ApplicationController
  prepend_before_action -> { authentication_check && authorize! }, except: [:webhook]
  skip_before_action :verify_csrf_token, only: [:webhook]

  def index
    assets = {}
    channel_ids = []
    Channel.where(area: 'Whatsapp::Bot').order(:id).each do |channel|
      assets = channel.assets(assets)
      channel_ids.push channel.id
    end
    render json: {
      assets:       assets,
      channel_ids:  channel_ids
    }
  end

  def add
    begin
      account_sid = params[:account_sid]
      channel = Whatsapp.create_or_update_channel(account_sid, params)
    rescue => e
      raise Exceptions::UnprocessableEntity, e.message
    end
    render json: channel
  end

  def update
    account_sid = params[:account_sid]
    channel = Channel.find_by(id: params[:id], area: 'Whatsapp::Bot')
    begin
      channel = Whatsapp.create_or_update_channel(account_sid, params, channel)
    rescue => e
      raise Exceptions::UnprocessableEntity, e.message
    end
    render json: channel
  end

  def enable
    channel = Channel.find_by(id: params[:id], area: 'Whatsapp::Bot')
    channel.active = true
    channel.save!
    render json: {}
  end

  def disable
    channel = Channel.find_by(id: params[:id], area: 'Whatsapp::Bot')
    channel.active = false
    channel.save!
    render json: {}
  end

  def destroy
    channel = Channel.find_by(id: params[:id], area: 'Whatsapp::Bot')
    channel.destroy
    render json: {}
  end

  def webhook
    # raise Exceptions::UnprocessableEntity, 'bot id is missing' if params['bid'].blank?

    # channel = Telegram.bot_by_bot_id(params['bid'])
    # raise Exceptions::UnprocessableEntity, 'bot not found' if !channel

 

    # telegram = Telegram.new(channel.options[:api_token])
    # begin
    #   telegram.to_group(params, channel.group_id, channel)
    # rescue Exceptions::UnprocessableEntity => e 
    #   Rails.logger.error e.message
    # end

    raise Exceptions::UnprocessableEntity, 'AccountSid is missing' if params['AccountSid'].blank?

    channel = Whatsapp.bot_by_account_sid(params['AccountSid'])
    raise Exceptions::UnprocessableEntity, 'bot not found' if !channel

    # TODO logica creazione article / ticket
    whatsapp = Whatsapp.new()
    begin
      whatsapp.to_group(params, channel.group_id, channel)
    rescue Exceptions::UnprocessableEntity => e
      Rails.logger.error e.message
    end

    render json: {}, status: :ok
  end

end

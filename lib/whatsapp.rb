class Whatsapp

    # # text of the message 
    # body = params["Body"]
    # # example: "whatsapp:+3934350548"
    # from = params["From"] 
    # # example "393546456546"
    # waid = params["WaId"]

    def self.bot_by_account_sid(account_sid)
      Channel.where(area: 'Whatsapp::Bot').each do |channel|
        next if !channel.options
        next if !channel.options[:account_sid]
        return channel if channel.options[:account_sid].to_s == account_sid.to_s
      end
      nil
    end

    def self.bot_duplicate?(account_sid, channel_id = nil)
      Channel.where(area: 'Whatsapp::Bot').each do |channel|
        next if !channel.options
        next if !channel.options[:account_sid]
        next if channel.options[:account_sid] != account_sid
        next if channel.id.to_s == channel_id.to_s
  
        return true
      end
      false
    end

    def self.create_or_update_channel(account_sid, params, channel = nil)

      # verify token
      # bot = Telegram.check_token(token)
  
      if !channel
        if Whatsapp.bot_duplicate?(account_sid)
          raise Exceptions::UnprocessableEntity, 'Bot already exists!'
        end
      end
  
      if params[:group_id].blank?
        raise Exceptions::UnprocessableEntity, 'Group needed!'
      end
  
      group = Group.find_by(id: params[:group_id])
      if !group
        raise Exceptions::UnprocessableEntity, 'Group invalid!'
      end
  
      # generate random callback token
      # callback_token = if Rails.env.test?
      #   'callback_token'
      # else
      #   SecureRandom.urlsafe_base64(10)
      # end

      # set webhook / callback url for this bot @ telegram
      # callback_url = "#{Setting.get('http_type')}://#{Setting.get('fqdn')}/api/v1/channels_whatsapp_webhook/#{callback_token}"
      # callback_url = "#{Setting.get('http_type')}://#{Setting.get('fqdn')}/external_credentials/whatsapp/callback"

  
      if !channel
        channel = Whatsapp.bot_by_account_sid(account_sid)
        if !channel
          channel = Channel.new
        end
      end
      channel.area = 'Whatsapp::Bot'
      channel.options = {
        # whatsapp_phone_number:  whatsapp_phone_number,
        # callback_token:         callback_token,
        # callback_url:           callback_url,
        bot_name:               params[:bot_name],
        auth_token:              params[:auth_token],
        phone:                  params[:phone],
        account_sid:            account_sid,
        # welcome:                params[:welcome],
        # goodbye:                params[:goodbye],
      }
      channel.group_id = group.id
      channel.active = true
      channel.save!
      channel
    end

    def to_group(params, group_id, channel)
      Rails.logger.debug { 'import message' }
      ticket = nil
      # use transaction
      Transaction.execute(reset_user_id: true) do
        user   = to_user(params)
        ticket = to_ticket(params, user, group_id, channel)
        to_article(params, user, ticket, channel)
      end
  
      return ticket if ticket
    end

    def user(params)
      if params["ProfileName"] and params["ProfileName"].split(" ")[0]
        first_name = params["ProfileName"].split(" ")[0]
      end
      if params["ProfileName"] and params["ProfileName"].split(" ")[0]
        last_name = params["ProfileName"].split(" ")[1]
      end
      {
        id:         params["WaId"],
        username:   params["WaId"],
        first_name: first_name,
        last_name:  last_name
      }
    end


    def to_user(params)
      Rails.logger.debug { 'Create user from message...' }
      Rails.logger.debug { params.inspect }
  
      # do message_user lookup
      message_user = user(params)
  
      auth = Authorization.find_by(uid: message_user[:id], provider: 'whatsapp')
  
      # create or update user
      login = message_user[:username] || message_user[:id]
      user_data = {
          login:     login,
          firstname: message_user[:first_name],
          lastname:  message_user[:last_name],
      }
      if auth
          user = User.find(auth.user_id)
          user.update!(user_data)
      else
          if message_user[:username]
              user_data[:note] = "Whatsapp @#{message_user[:username]}"
          end
          user_data[:active]   = true
          user_data[:role_ids] = Role.signup_role_ids
          user                 = User.create(user_data)
      end
  
      # create or update authorization
      auth_data = {
          uid:      message_user[:id],
          username: login,
          user_id:  user.id,
          provider: 'whatsapp'
      }
      if auth
          auth.update!(auth_data)
      else
          Authorization.create(auth_data)
      end
      user
  end


  def to_ticket(params, user, group_id, channel)
    UserInfo.current_user_id = user.id

    Rails.logger.debug { 'Create ticket from message...' }
    Rails.logger.debug { params.inspect }
    Rails.logger.debug { user.inspect }
    Rails.logger.debug { group_id.inspect }

    # prepare title
    title = '-'
    %i[Body].each do |area|
      next if !params
      next if !params[area]

      title = params[area]
      break
    end
    # if title == '-'
    #   %i[sticker photo document voice].each do |area|

    #     next if !params[:message]
    #     next if !params[:message][area]
    #     next if !params[:message][area][:emoji]

    #     title = params[:message][area][:emoji]
    #     break
    #   rescue
    #     # just go ahead
    #     title

    #   end
    # end
    if title.length > 60
      title = "#{title[0, 60]}..."
    end

    # find ticket or create one
    state_ids        = Ticket::State.where(name: %w[closed merged removed]).pluck(:id)
    possible_tickets = Ticket.where(customer_id: user.id).where.not(state_id: state_ids).order(:updated_at)
    ticket           = possible_tickets.find_each.find { |possible_ticket| possible_ticket.preferences[:channel_id] == channel.id  }

    if ticket
      # check if title need to be updated
      if ticket.title == '-'
        ticket.title = title
      end
      new_state = Ticket::State.find_by(default_create: true)
      if ticket.state_id != new_state.id
        ticket.state = Ticket::State.find_by(default_follow_up: true)
      end
      ticket.save!
      return ticket
    end

    ticket = Ticket.new(
      group_id:    group_id,
      title:       title,
      state_id:    Ticket::State.find_by(default_create: true).id,
      priority_id: Ticket::Priority.find_by(default_create: true).id,
      customer_id: user.id,
      preferences: {
        channel_id: channel.id,
        whatsapp:   {
          bot_phone:          params["To"],
          account_sid:  	    params["AccountSid"],
          customer_phone:     params["From"]
        #   chat_id: params[:message][:chat][:id]
        }
      },
    )
    ticket.save!
    ticket
  end


  def to_article(params, user, ticket, channel, article = nil)
 
    if article
      Rails.logger.debug { 'Update article from message...' }
    else
      Rails.logger.debug { 'Create article from message...' }
    end
    Rails.logger.debug { params.inspect }
    Rails.logger.debug { user.inspect }
    Rails.logger.debug { ticket.inspect }

    UserInfo.current_user_id = user.id

    if article
      article.preferences[:edited_message] = {
        message:   {
          # created_at: params[:message][:date],
          message_id: params["MessageSid"],
          from:       params["From"],
        },
        # update_id: params[:update_id],
      }
    else
      article = Ticket::Article.new(
        ticket_id:   ticket.id,
        type_id:     Ticket::Article::Type.find_by(name: 'whatsapp personal-message').id,
        sender_id:   Ticket::Article::Sender.find_by(name: 'Customer').id,
        from:        "#{user(params)[:username]} (#{params["From"]})",
        to:          "Zammad Whatsapp Channel (#{params["To"]})",
        # to:          "#{channel[:options][:bot][:id]}",
        # message_id:  Telegram.message_id(params),
        internal:    false,
        preferences: {
          message:   {
            # created_at: params[:message][:date],
            message_id: params["MessageSid"],
            from:       params["From"],
          },
          # update_id: params[:update_id],
        }
      )
    end

    # add text
    if params["Body"]
      article.content_type = 'text/plain'
      article.body = params["Body"]
      article.save!
      return article
    end
    raise Exceptions::UnprocessableEntity, 'invalid whatsapp message'
  end



end

class Observer::Ticket::Article::CommunicateWhatsapp::BackgroundJob
  def initialize(id)
    @article_id = id
  end

  def perform
    article = Ticket::Article.find(@article_id)

    # set retry count
    article.preferences['delivery_retry'] ||= 0
    article.preferences['delivery_retry'] += 1

    ticket = Ticket.lookup(id: article.ticket_id)
    log_error(article, "Can't find ticket.preferences for Ticket.find(#{article.ticket_id})") if !ticket.preferences
    log_error(article, "Can't find ticket.preferences['whatsapp'] for Ticket.find(#{article.ticket_id})") if !ticket.preferences['whatsapp']
    
    
    
    
    # log_error(article, "Can't find ticket.preferences['whatsapp']['chat_id'] for Ticket.find(#{article.ticket_id})") if !ticket.preferences['telegram']['chat_id']
    if ticket.preferences['whatsapp'] && ticket.preferences['whatsapp']['account_sid']
      channel = Whatsapp.bot_by_account_sid(ticket.preferences['whatsapp']['account_sid'])
    end
    if !channel
      channel = Channel.lookup(id: ticket.preferences['channel_id'])
    end
    # log_error(article, "No such channel for bot #{ticket.preferences['bid']} or channel id #{ticket.preferences['channel_id']}") if !channel
    #log_error(article, "Channel.find(#{channel.id}) isn't a telegram channel!") if channel.options[:adapter] !~ /\Atelegram/i
    # log_error(article, "Channel.find(#{channel.id}) has not telegram api token!") if channel.options[:api_token].blank?

    begin

      from_number = ticket.preferences['whatsapp']['bot_phone']
      # to_number = 'whatsapp:+3936717898'
      to_number = ticket.preferences['whatsapp']['customer_phone']
      if not to_number.include?('whatsapp:')
        to_number = "whatsapp:#{to_number}"
      end
      
      # account_sid = 'AC6dc3ba07c4922b53b349b0dec8919a05' 
      # auth_token = '5673e1ab20ff9447a3ad8789fafc2c75' 
      account_sid = channel.options["account_sid"]
      auth_token = channel.options["auth_token"]
      @client = Twilio::REST::Client.new(account_sid, auth_token) 
      
      message = @client.messages.create( 
                                  body: article.body, 
                                  from: from_number,       
                                  to:  to_number
                                ) 
      
      # puts message.sid


      # api = TelegramAPI.new(channel.options[:api_token])
      # chat_id = ticket.preferences[:telegram][:chat_id]
      # result = api.sendMessage(chat_id, article.body)
      # me = api.getMe()
      # article.attachments.each do |file|
      #   parts = file.filename.split(/^(.*)(\..+?)$/)
      #   t = Tempfile.new([parts[1], parts[2]])
      #   t.binmode
      #   t.write(file.content)
      #   t.rewind
      #   api.sendDocument(chat_id, t.path.to_s)
      # end

    rescue => e
      log_error(article, e.message)
      return
    end

    Rails.logger.debug { "result info: #{message}" }

    
    # fill article with message info
    article.from = "Zammad Whatsapp Channel (#{from_number})"
    article.to = "#{ticket.customer.firstname} #{ticket.customer.lastname} (#{to_number})"

    article.preferences['whatsapp'] = {
      date:       message.date_updated,
      from_id:    from_number,
      # chat_id:    result['chat']['id'],
      message_id: message.sid
    }
   

    # set delivery status
    article.preferences['delivery_status_message'] = nil
    article.preferences['delivery_status'] = 'success'
    article.preferences['delivery_status_date'] = Time.zone.now

    article.message_id = "whatsapp.#{message.sid}"

    article.save!

    Rails.logger.info "Send whatsapp message to: '#{article.to}' (from #{article.from})"

    article
  end

  def log_error(local_record, message)
    local_record.preferences['delivery_status'] = 'fail'
    local_record.preferences['delivery_status_message'] = message.encode!('UTF-8', 'UTF-8', invalid: :replace, replace: '?')
    local_record.preferences['delivery_status_date'] = Time.zone.now
    local_record.save
    Rails.logger.error message

    if local_record.preferences['delivery_retry'] > 3
      Ticket::Article.create(
        ticket_id:     local_record.ticket_id,
        content_type:  'text/plain',
        body:          "Unable to send whatsapp message: #{message}",
        internal:      true,
        sender:        Ticket::Article::Sender.find_by(name: 'System'),
        type:          Ticket::Article::Type.find_by(name: 'note'),
        preferences:   {
          delivery_article_id_related: local_record.id,
          delivery_message:            true,
        },
        updated_by_id: 1,
        created_by_id: 1,
      )
    end

    raise message
  end

  def max_attempts
    4
  end

  def reschedule_at(current_time, attempts)
    if Rails.env.production?
      return current_time + attempts * 120.seconds
    end

    current_time + 5.seconds
  end
end

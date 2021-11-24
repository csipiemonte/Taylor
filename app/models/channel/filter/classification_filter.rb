module Channel::Filter::ClassificationFilter

  def self.run(_channel, mail, ticket = nil, _article = nil, _session_user = nil)
    return true if Setting.get('classification_engine_enabled') != true

    begin
      if ticket
        Rails.logger.info "CLASSIFICATION FILTER POST - ticket: #{ticket}"
        tag = mail['classification']
        Rails.logger.info "CLASSIFICATION FILTER POST - tag: #{tag}"
        if tag
          ticket.tag_add(tag, 1)
          ticket.save!
        end
        return true
      end

      body = mail[:body].html2text
      Rails.logger.info "CLASSIFICATION FILTER PRE - body: #{body}"
      subject = mail[:subject].html2text
      Rails.logger.info "CLASSIFICATION FILTER PRE - subject: #{subject}"

      response = UserAgent.post(
        "#{Setting.get('classification_engine_api_settings')}/predict",
        {
          'data':      [ { 'content': body, 'subject': subject } ],
          'threshold': 0.6
        },
        { json: true }
      )

      if !response.success?
        Rails.logger.error "Errore occorso durante l'invocazione del Classification Engine, dettaglio: #{response.error}"
        return
      end

      # risosta composta dai campi [{"confidence" => <indice_confidenza>, "class" = > <classificazione>}]
      body_resp = JSON.parse(response.body)
      Rails.logger.info "CLASSIFICATION FILTER PRE - body_resp: #{body_resp}"
      if body_resp && body_resp['class']
        mail['classification'] = body_resp['class'] if body_resp['class'] != 'NORESPONSE'
      end
    rescue => e
      Rails.logger.error "A problem occured during ticket classification.\n#{e.backtrace}"
    ensure
      true
    end
    true
  end
end

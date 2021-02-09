module Channel::Filter::ClassificationFilter

  def self.run(_channel, mail, ticket = nil, _article = nil, _session_user = nil)
    if !ticket
      body = mail[:body].html2text
      Rails.logger.info "CLASSIFICATION FILTER PRE - body: #{body}"
      subject = mail[:subject].html2text
      Rails.logger.info "CLASSIFICATION FILTER PRE - subject: #{subject}"
      text = subject+" "+subject+" "+body
      response = ClassificationEngineService.classify(text,0.8)
      Rails.logger.info "CLASSIFICATION FILTER PRE - response: #{response}"
      if response
        mail["classification"] = response["classification"] && response["classification"]!="NORESPONSE" ? response["classification"] : response["proposed_classification"] ? response["proposed_classification"] : nil
      end
      true
    else
      Rails.logger.info "CLASSIFICATION FILTER POST - ticket: #{ticket}"
      tag = mail["classification"]
      Rails.logger.info "CLASSIFICATION FILTER POST - tag: #{tag}"
      if tag
        ticket.tag_add(tag,1)
        ticket.save!
      end
      true
    end
    true
  end


end

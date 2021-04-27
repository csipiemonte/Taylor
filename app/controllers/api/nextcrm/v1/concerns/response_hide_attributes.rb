module Api::Nextcrm::V1::Concerns::ResponseHideAttributes
  extend ActiveSupport::Concern


  # work on array of articles
  def hideTicketAttributesInResponse
    states_to_hide_array = Ticket::State.select(:id,:name,:external_state_id).where.not(external_state_id: nil).where(active: true).to_a
    # convert to hash {id => object} to improve access lookup speed in loop
    states_to_hide_hash = states_to_hide_array.to_h{|state| [state.id, state] }
    states_to_hide_ids = states_to_hide_hash.keys
    # convert array in Set to improve 'include?' lookup speed in loop
    states_to_hide_ids = states_to_hide_ids.to_s
    # optimized json parse
    obj_resp = Oj.load(response.body)

    if obj_resp.is_a? Array
      # loop over response array of tickets to hide/change attributes
      obj_resp.each do |ticket| 
        ticket.delete("article_ids")
        ticket.delete("group_id")
        ticket.delete("owner_id")
        if states_to_hide_ids.include?(ticket["state_id"].to_s)
          ticket["state_id"]  = states_to_hide_hash[ticket["state_id"]].external_state_id
        end
      end
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp

    end
  end

  # work on array of articles
  def hideInternalArticles
    # optimized json parse
    obj_resp = Oj.load(response.body)
    if obj_resp.is_a? Array
      # override response array of articles with a selection of internal only articles 
      obj_resp = obj_resp.select { |article| article['internal'] == false }
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    end
  end

end
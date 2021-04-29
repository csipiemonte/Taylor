# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ExternalTicketsController < TicketsController

  # GET /api/v1/tickets
  def index
    super
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
        if states_to_hide_ids.include?(ticket["state_id"].to_s)
          ticket["state_id"]  = states_to_hide_hash[ticket["state_id"]].external_state_id
        end
      end
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    end
  end

  def show
    super
    ticket = Oj.load(response.body)
    public_state = Ticket::State.find_by(id: ticket["state_id"]).external_state_id
    if public_state
      ticket["state_id"] = public_state
    end
    str_resp = Oj.dump(ticket)
    response.body = str_resp
  end

end

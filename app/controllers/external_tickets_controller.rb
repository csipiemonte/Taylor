# Copyright (C) 2021 CSI Piemonte, https://www.csipiemonte.it/

# Controller custom CSI Piemonte che estende il controller VirtualAgentTicketsController che, a sua volta,
# estende il controller TicketsController
# Le invocazioni delle API con "/api/v1/public/tickets" sono redirette su questo controller
# invece che sul controller nativo Zammad
# Lo scopo di questo controller e' quello di nascondere gli stati che non devono essere visibili al chiamante.
class ExternalTicketsController < VirtualAgentTicketsController

  # GET /api/v1/tickets
  def index
    super

    # external_state_id indica gli stati visibili all'esterno
    @states_to_hide_array = Ticket::State.select(:id, :name, :external_state_id).where.not(external_state_id: nil).where(active: true).to_a

    # convert to hash {id => object} to improve access lookup speed in loop
    @states_to_hide_hash = @states_to_hide_array.to_h { |state| [state.id, state] }
    @states_to_hide_ids = @states_to_hide_hash.keys
    # convert array in Set to improve 'include?' lookup speed in loop
    @states_to_hide_ids = @states_to_hide_ids.to_s
    # optimized json parse
    obj_resp = Oj.load(response.body)

    if obj_resp.is_a? Array
      # loop over response array of tickets to hide/change attributes
      obj_resp.each do |ticket|
        hide_state ticket
      end
    else
      hide_state obj_resp
    end
    str_resp = Oj.dump(obj_resp)
    response.body = str_resp
  end

  def show
    super
    ticket = Oj.load(response.body)
    public_state = Ticket::State.find_by(id: ticket['state_id']).external_state_id
    if public_state
      ticket['state_id'] = public_state
    end
    str_resp = Oj.dump(ticket)
    response.body = str_resp
  end

  private

  # Metodo privato per nascondere alcuni stati
  # Se lo stato del ticket (state_id) e' presente nell'array @states_to_hide_ids,
  # viene sostituito con il valore presente in @states_to_hide_hash (se previsto valore).
  def hide_state (ticket)
    return unless @states_to_hide_ids.include?(ticket['state_id'].to_s)

    state = @states_to_hide_hash[ticket['state_id']]
    return unless state

    ticket['state_id'] = @states_to_hide_hash[ticket['state_id']].external_state_id
  end
end

class ExternalActivityTicketsController < TicketOverviewsController
  def show
    super
    return if params[:view].blank?

    obj_resp = Oj.load(response.body)
    return response.body unless obj_resp['assets']['Ticket']

    obj_resp['assets']['Ticket'].each do |ticket|
      include_external_activity_flag ticket[1]
    end
    str_resp = Oj.dump(obj_resp)
    response.body = str_resp
  end

  private

  def include_external_activity_flag (ticket)
    ExternalActivity.where(ticket_id: ticket['id']).each do |activity|
      next unless activity.needs_attention

      ticket['needs_attention'] = true
    end
  end
end

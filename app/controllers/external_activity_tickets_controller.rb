# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class ExternalActivityTicketsController < TicketOverviewsController

  def show
    super
    if params[:view].present?
      obj_resp = Oj.load(response.body)
      tickets = obj_resp["assets"]["Ticket"]
      tickets.each do |ticket|
        include_external_activity_flag ticket[1]
      end
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    end
  end

  def include_external_activity_flag (ticket)
    ExternalActivity.where(ticket_id:ticket["id"]).each do |activity|
      if activity.needs_attention
        ticket["needs_attention"] = true
      end
    end
  end

end

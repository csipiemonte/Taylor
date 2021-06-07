# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class Transaction::Trigger

=begin
  {
    object: 'Ticket',
    type: 'update',
    object_id: 123,
    interface_handle: 'application_server', # application_server|websocket|scheduler
    changes: {
      'attribute1' => [before, now],
      'attribute2' => [before, now],
    },
    created_at: Time.zone.now,
    user_id: 123,
  },
=end

  def initialize(item, params = {})
    @item = item
    @params = params
  end

  def perform
    Rails.logger.info { "transaction/trigger.rb - perform @item #{@item}, @params #{@params}" }
    # per ExternalActivity la riga di log produce
    # item : {:object=>"ExternalActivity", :object_id=>1, :user_id=>1, :created_at=>Mon, 07 Jun 2021 09:36:27 UTC +00:00,
    # :type=>"update", :changes=>{"bidirectional_alignment"=>[true, false]}
    # },
    # params: {:interface_handle=>"application_server", :type=>"update", :reset_user_id=>true, :disable=>["Transaction::Notification"], :trigger_ids=>{4=>[8]}, :loop_count=>1}

    # return if we run import mode
    return if Setting.get('import_mode')

    return if @item[:object] != 'Ticket' && @item[:object] != 'ExternalActivity' # CSI custom, aggiunta condizione su 'ExternalActivity'

    if @item[:object] == 'Ticket'
      ticket = Ticket.find_by(id: @item[:object_id])
    end

    # CSI custom
    if @item[:object] == 'ExternalActivity'
      external_activity = ExternalActivity.find_by(id: @item[:object_id])
      ticket = Ticket.find_by(id: external_activity.ticket_id)
    end

    return if !ticket

    if @item[:article_id]
      article = Ticket::Article.find_by(id: @item[:article_id])
    end

    original_user_id = UserInfo.current_user_id

    Ticket.perform_triggers(ticket, article, @item, @params, external_activity)
    UserInfo.current_user_id = original_user_id
  end

end

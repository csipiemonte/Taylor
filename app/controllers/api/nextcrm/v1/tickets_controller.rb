class Api::Nextcrm::V1::TicketsController < ::TicketsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::Filterable
  include Api::Nextcrm::V1::Concerns::ResponseHideAttributes

  def index
    super
    hideTicketAttributesInResponse()
  end

  def search
    params[:expand] = true
    if params[:filter]
      filter = JSON.parse(params[:filter])
      query = filterToElasticSearchQuery(filter)
      params[:query] = query
    end
    super
    hideTicketAttributesInResponse()
  end

  # al momento non utilizzata
  def filter_updated

    from_time = params[:from]
    to_time = params[:to]

    ### TODO impostare massimo from-to a 1 mese ###

    per_page = params[:per_page] || params[:limit] || 50
    per_page = per_page.to_i
    if per_page > 200
      per_page = 200
    end
    page = params[:page] || 1
    page = page.to_i
    offset = (page - 1) * per_page


    ########################### TODO  spostare in model concern ##
    limit = per_page
    sort_by = ["updated_at"]
    order_by = ["desc"]
    # user read permissions on groups
    access_condition = Ticket.access_condition(current_user, 'read')


    # order_select_sql = search_get_order_select_sql(sort_by, order_by, 'tickets.updated_at')
    # order_sql        = search_get_order_sql(sort_by, order_by, 'tickets.updated_at DESC')
    order_select_sql = ' "tickets"."updated_at"'
    order_sql        = '"tickets"."updated_at" desc'

   
    # if db cast on date is needed #.where( "date(valid_date) BETWEEN ? AND ? ", start_date, end_date)
    ## add where updated_at different from created_at
    tickets_all = Ticket.select("DISTINCT(tickets.id), #{order_select_sql}")
                        .where(access_condition)
                        .where(:updated_at => from_time..to_time)
                        .order(Arel.sql(order_sql))
                        .offset(offset)
                        .limit(limit)

    tickets = []
    tickets_all.each do |ticket|
      tickets.push Ticket.lookup(id: ticket.id)
    end
    ##############################

    list = tickets


    
    render json: list, status: :ok
    return
  end

  def show
    super
  end

  def create
   
    params.delete :owner_id
    params.delete :owner

    params.delete :state
    params[:state_id] = 1 # new # TODO (solo) il valore 1 viene sovrascritto, da capire dove
    
    
    if params[:article] and not params[:article][:type_id]
      raise Exceptions::UnprocessableEntity, "Need at least article: { type_id: \"<id>\" "
    end
    if params[:ticket] and params[:ticket][:customer_id]
      params[:ticket][:customer_id] = "guess:#{params[:ticket][:customer_id]}"
    end
    super
  end

  def update

    params.delete :owner_id
    params.delete :owner

    params.delete :state
    if params[:state_id] and params[:state_id] != 4 # closed
      raise Exceptions::UnprocessableEntity, "Available ticket state id: [4]"
    end
    
    if params[:ticket] and params[:ticket][:customer_id]
      # check if input email is present as linked account 
      value = params[:ticket][:customer_id]
      linked_authorization = Authorization.where(email: value).last
      if linked_authorization
        user = User.where(id: linked_authorization.user_id).last
        if user and user.email
          value = user.email
        end
      end
      # autocreate user if not exists with "guess" keywork
      params[:ticket][:customer_id] = "guess:#{value}"
    end
    super
  end


  private

  def hideTicketAttributesInResponse
    whitelist_parameters = %w[
      id 
      priority_id 
      state_id 
      organization_id 
      number 
      title 
      customer_id 
      note 
      first_response_at 
      first_response_escalation_at 
      first_response_in_min 
      first_response_diff_in_min 
      close_at 
      close_escalation_at 
      close_in_min 
      close_diff_in_min 
      update_escalation_at 
      update_in_min 
      update_diff_in_min 
      last_contact_at 
      last_contact_agent_at 
      last_contact_customer_at 
      last_owner_update_at 
      create_article_type_id 
      create_article_sender_id 
      article_count escalation_at 
      pending_time type time_unit 
      preferences updated_by_id 
      created_by_id created_at 
      updated_at 
      remedy_id 
      prova_richiesta_field 
      utente_riconosciuto 
      service_catalog_item_id 
      service_catalog_sub_item_id 
      asset_id 
      ticket_time_accounting_ids 
      group 
      ticket_time_accounting 
      state 
      priority 
      owner 
      customer 
      created_by 
      updated_by 
      create_article_type 
      create_article_sender
    ].to_set

    states_to_hide_array = Ticket::State.select(:id,:name,:external_state_id).where.not(external_state_id: nil).where(active: true).to_a
    # convert to hash {id => object} to improve access lookup speed in loop
    states_to_hide_hash = states_to_hide_array.to_h{|state| [state.id, state] }
    states_to_hide_ids = states_to_hide_hash.keys
    # convert array in Set to improve 'include?' lookup speed in loop
    states_to_hide_ids = states_to_hide_ids.to_set
    # optimized json parse
    obj_resp = Oj.load(response.body)

    if obj_resp.is_a? Array
      # loop over response array of tickets to hide/change attributes
      obj_resp.each do |ticket| 
        # whitelist
        ticket.keys.each do |attribute|
          ticket.delete(attribute) unless whitelist_parameters.include?(attribute)
        end

        if states_to_hide_ids.include?(ticket["state_id"].to_s) and states_to_hide_hash[ticket["state_id"]]
          ticket["state_id"]  = states_to_hide_hash[ticket["state_id"]].external_state_id
        end
      end
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp

    end
  end


  
end
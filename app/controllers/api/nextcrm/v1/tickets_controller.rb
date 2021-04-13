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

    params.delete :state_id
    params.delete :state
    
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
      params[:ticket][:customer_id] = "guess:#{params[:ticket][:customer_id]}"
    end
    super
  end





end
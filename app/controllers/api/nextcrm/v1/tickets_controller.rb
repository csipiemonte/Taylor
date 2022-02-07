class Api::Nextcrm::V1::TicketsController < ::VirtualAgentTicketsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt
  include Api::Nextcrm::V1::Concerns::Filterable
  include Api::Nextcrm::V1::Concerns::CustomApiLogger


  def index
    params[:expand] = true
    super
    alterTicketAttributesInResponse()
  end

  def search
    params[:expand] = true
    if params[:filter]
      filter = JSON.parse(params[:filter])
      query = filterToElasticSearchQuery(filter)
      params[:query] = query
    end
    super
    alterTicketAttributesInResponse()
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
    params[:expand] = true
    super
    alterTicketAttributesInResponse()
  end

  def create
    apilogger.info {"init ticket create business logic"}
    apilogger.info {"raw input params: #{params.filtered}"}
    
    # apilogger.info {"input parameters: "} # TODO filtrare campi lunghi/file/password

    params[:expand] = true
    params.delete :owner_id
    params.delete :owner

    params.delete :state
    params[:state_id] = 1 # new 

    if params[:utente_riconosciuto] && params[:utente_riconosciuto].is_a?(String)
      # TODO togliere una volta implementata tabella lookup. modificare per mantenere retrocompatibilità con si / no per CSP
      if params[:utente_riconosciuto].underscore == 'no'
        params[:utente_riconosciuto] = 0
      elsif params[:utente_riconosciuto].underscore == 'si'
        params[:utente_riconosciuto] = 1
      else
        params.delete :utente_riconosciuto 
      end
    end
    
    
    if params[:article] 
      if not params[:article][:type_id]
        raise Exceptions::UnprocessableEntity, "Need at least article: { type_id: \"<integer>\"} "
      end
      if not params[:article][:from]
        raise Exceptions::UnprocessableEntity, "Need at least article: { from: \"<string>\"} "
      end
      if not params[:article][:from].match(URI::MailTo::EMAIL_REGEXP)
        raise Exceptions::UnprocessableEntity, "Must be a valid email:  article: { from: \"<string>\"} "
      end
      # sender_id di default viene valorizzato a 1 (Agent) e in questo caso app/models/observer/reset_new_state.rb setta lo state_id a 2 (aperto)
      params[:article][:sender_id] = 2 # indica che il testo del ticket (article) e'stato creato da un Customer
    end
    handle_user_on_create()

    # issue 488, rinomina type_id (input) -> ticket_type_id (output)
    params["ticket_type_id"] = params.delete("type_id")

    apilogger.info {"business logic end"}
    apilogger.info {"modified input params, before invoking zammad core controller : #{params.filtered}"}
    super
    apilogger.info {"zammad core create end. processing output response"}
    alterTicketAttributesInResponse()
    apilogger.info {"api create method end"}
  end

  def update
    apilogger.info {"init ticket update business logic"}
    apilogger.info {"raw input params: #{params.filtered}"}
    params[:expand] = true
    params.delete :owner_id
    params.delete :owner

    if params[:utente_riconosciuto] && params[:utente_riconosciuto].is_a?(String)
      # TODO togliere una volta implementata tabella lookup. modificare per mantenere retrocompatibilità con si / no per CSP
      if params[:utente_riconosciuto].underscore == 'no'
        params[:utente_riconosciuto] = 0
      elsif params[:utente_riconosciuto].underscore == 'si'
        params[:utente_riconosciuto] = 1
      else
        params.delete :utente_riconosciuto 
      end
    end

    params.delete :state
    if params[:state_id] 
      # 4:chiuso 1:nuovo 9:in attesa di informazioni da utente
      if [1,4,9, "1","4","9"].include? params[:state_id]
        raise Exceptions::UnprocessableEntity, "forbidden ticket state id"
      end
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

    # issue 488, rinomina type_id (input) -> ticket_type_id (output)
    params["ticket_type_id"] = params.delete("type_id")

    apilogger.info {"modified input params, before invoking zammad core controller : #{params.filtered}"}
    super
    apilogger.info {"zammad core create end. processing output response"}
    alterTicketAttributesInResponse()
    apilogger.info {"api update method end"}
  end


  private

  def alterTicketAttributesInResponse

    # convert to hash {id => object} to improve access lookup speed in loop
    all_assets = Asset.select(:id,:name).to_a.to_h{|asset| [asset.id, asset.name] }
    states_to_hide_array = Ticket::State.select(:id,:name,:external_state_id).where.not(external_state_id: nil).where(active: true).to_a
    # convert to hash {id => object} to improve access lookup speed in loop
    states_to_hide_hash = states_to_hide_array.to_h{|state| [state.id, state] }
    states_to_hide_ids = states_to_hide_hash.keys
    # convert array in Set to improve 'include?' lookup speed in loop
    states_to_hide_ids = states_to_hide_ids.to_set
    # translated states in hash {source name => translated name} to improve access lookup speed in loop
    states_traslations = Ticket::State.select(:id,:name).where(active: true).to_a.to_h{|state| [state.name,  Translation.translate('it-it', state.name)] }
    # optimized json parse
    obj_resp = Oj.load(response.body)

    if obj_resp.is_a? Array
      # loop over response array of tickets to hide/change attributes
      obj_resp.each do |ticket| 
        modify_ticket(ticket, all_assets, states_to_hide_hash , states_to_hide_ids, states_traslations)
      end
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    else
      ticket = obj_resp
      modify_ticket(ticket, all_assets, states_to_hide_hash , states_to_hide_ids, states_traslations)
      str_resp = Oj.dump(obj_resp)
      response.body = str_resp
    end
  end

  def modify_ticket(ticket, all_assets, states_to_hide_hash , states_to_hide_ids, states_traslations)
    whitelist_parameters = %w[
      id 
      priority_id 
      priority
      state_id 
      state
      number 
      title 
      customer_id 
      customer 
      note 
      article_count  
      type 
      ticket_type
      ticket_type_id
      utente_riconosciuto 
      asset_id 
      asset
      created_at 
      updated_at 
      create_article_type 
      create_article_sender
      external_activities

      additional_info
      notification_email
      recall_phone

    ].to_set

    # whitelist
    ticket.keys.each do |attribute|
      ticket.delete(attribute) unless whitelist_parameters.include?(attribute)
    end
    # internal states subtitution
    if states_to_hide_ids.include?(ticket["state_id"].to_s) and states_to_hide_hash[ticket["state_id"]]
      ticket["state_id"]  = states_to_hide_hash[ticket["state_id"]].external_state_id
    end
    # state translation
    ticket["state"] = states_traslations[ticket["state"]] if ticket["state"]
    # asset name
    ticket["asset"] ||= nil

    # TODO rimuovere quando implementata tabella lookup
    ticket["utente_riconosciuto"] = ticket["utente_riconosciuto"].to_i

    # issue 488, rinomina ticket_type_id -> type_id e ticket_type -> type
    ticket["type_id"] = ticket.delete("ticket_type_id")
    ticket["type"] = ticket.delete("ticket_type")

    if ticket["asset_id"] 
      ticket["asset"] = all_assets[ticket["asset_id"]]
    end
  end

  def handle_user_on_create

    customer = params[:customer]
    if customer.nil? or customer[:email].nil? or customer[:email].blank?
      apilogger.error {"[API] create ticket without customer email.. customer: #{customer.to_s}"}
      raise Exceptions::UnprocessableEntity, "Need at least customer: { email: \"<string>\"} "
    end

    # se utente verificato
    if params[:utente_riconosciuto] == 1
      apilogger.info{"utente_riconosciuto: true"}
      # controllo esistenza utente
      user = check_user_exists(customer)

      # se utente esiste
      if user
        apilogger.info{"found customer user on db with id: #{user.id}. updating existing db customer with parameters customer data"}
        # aggiorno "dati verificati" sul db. zammad lo riconoscerà come utente destinatario del ticket
        user.verified_data = true
        user.firstname = customer[:firstname] if customer[:firstname]
        user.lastname = customer[:lastname] if customer[:lastname]
        user.phone = customer[:phone] if customer[:phone]
        user.email = customer[:email] if customer[:email]
        user.fax = customer[:fax] if customer[:fax]
        user.mobile = customer[:mobile] if customer[:mobile]
        user.note = customer[:note] if customer[:note]
        user.codice_fiscale = customer[:codice_fiscale] if customer[:codice_fiscale]
        user.codice_fiscale = customer[:birthdate] if customer[:birthdate]
        user.codice_fiscale = customer[:city] if customer[:city]
        user.codice_fiscale = customer[:country] if customer[:country]
        user.codice_fiscale = customer[:street] if customer[:street]
        user.codice_fiscale = customer[:zip] if customer[:zip]

        user.save! # scatta exception se non va a buon fine
        apilogger.info{"customer data updated"}
      # se utente non esiste
      else
        apilogger.info{"customer user not found. creating new user with customer input parameters and verified_data: true"}
        # aggiorno i params in modo che lo user venga creato con flag "dati verificati"
        customer['verified_data'] = true
      end
      
    # se utente aninimo / non verificato
    else
      apilogger.info{"utente_riconosciuto: false updating ticket not_verified_* fields with cusomer input parameters"}
      customer['verified_data'] = false
      # utente non riconosciuto: compilo i campi sul ticket
      params[:not_verified_user_firstname] = customer[:firstname]
      params[:not_verified_user_lastname] = customer[:lastname]
      params[:not_verified_user_codice_fiscale] = customer[:codice_fiscale]
      params[:not_verified_user_mobile] = customer[:mobile]
      params[:not_verified_user_phone] = customer[:phone]

      # elimino il codice fiscale per evitare ricerca utente esistente su codice fiscale
      # per evitare di associarlo ad altri utenti aventi quel codice fiscale, e ricevere comunque risposta sulla e-mail di un impostore che ha usato il mio codfisc
      # e per evitare , se è cambiata la mail, che venga creato uno user con stesso cod fisc  (darebbe errore unique) 
      customer.delete :codice_fiscale
      apilogger.info{"remove 'codice fiscale' from customer input parameters"}

      # controllo esistenza utente
      user = check_user_exists(customer)

      if user
        apilogger.info{"found customer user on db with id: #{user.id}"}
        # associo il ticket all'utente trovato. la mail potrebbe non corrispondere se è una linked email
        params.delete :customer
        params[:customer_id] = user.id
      else
        apilogger.info{"customer user not found. creating new user (not verified)"}
      end
    
    end

  end

  def check_user_exists(customer)
    user = User.find_by(codice_fiscale: customer['codice_fiscale']) if customer['codice_fiscale']

    if not user
      linked_authorization = Authorization.where(email: customer['email']).last
      if linked_authorization
        user = User.where(id: linked_authorization.user_id).last
      end
    end

    if not user 
      user = User.find_by(email: customer['email']) 
    end
    return user
  end

  
end
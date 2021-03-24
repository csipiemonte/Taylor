class RemedyController < ApplicationController
  include CreatesTicketArticles
  include ClonesTicketArticleAttachments
  include ChecksUserAttributesByCurrentUserPermission
  include TicketStats

  prepend_before_action { authentication_check && authorize! }

  # GET /api/v1/remedy_tickets
  def index
    tickets = Ticket.where("tickets.remedy_id IS NOT NULL")   #.order(id: :asc).offset(offset).limit(per_page)
    if response_expand?
      list = []
      tickets.each do |ticket|
        list.push ticket.attributes_with_association_names
      end
      render json: list, status: :ok
      return
    end

    if response_full?
      assets = {}
      item_ids = []
      tickets.each do |item|
        item_ids.push item.id
        assets = item.assets(assets)
      end
      render json: {
        record_ids: item_ids,
        assets:     assets,
      }, status: :ok
      return
    end

    render json: tickets
  end

  # GET /api/v1/sync_remedy_tickets
  def sync
    state_mappings = Setting.get('remedy_ticket_state_mapping')
    tickets = Ticket.where("tickets.remedy_id IS NOT NULL")
    Rails.logger.info("[REMEDY INTEGRATION LOG] finding remedy tickets: #{tickets.length()} found")
    tickets.each do |ticket|
      state = RemedyApiService.get_ticket_status(ticket.remedy_id)["stato"].downcase
      Rails.logger.info("[REMEDY INTEGRATION LOG] mappings available: #{state_mappings}")
      Rails.logger.info("[REMEDY INTEGRATION LOG] remedy state : #{state}")
      Rails.logger.info("[REMEDY INTEGRATION LOG] mapped to: #{state_mappings[state.parameterize.underscore]}")
      state_id = state_mappings[state.parameterize.underscore]
      Rails.logger.info("[REMEDY INTEGRATION LOG] setting ticket's state_id to: #{state_id}")
      if ticket.state_id != state_id && state_id
        ticket.state_id = state_id
        ticket.save!
      end
    end
  end

  # POST /api/v1/create_remedy_ticket
  def create
    customer = {}
    if params[:customer].class == ActionController::Parameters
      customer = params[:customer]
      params.delete(:customer)
    end

    clean_params = Ticket.association_name_to_id_convert(params)

    # overwrite params
    if !current_user.permissions?('ticket.agent')
      %i[owner owner_id customer customer_id organization organization_id preferences].each do |key|
        clean_params.delete(key)
      end
      clean_params[:customer_id] = current_user.id
    end

    # try to create customer if needed
    if clean_params[:customer_id].present? && clean_params[:customer_id] =~ /^guess:(.+?)$/
      email_address = $1
      email_address_validation = EmailAddressValidation.new(email_address)
      if !email_address_validation.valid_format?
        render json: { error: "Invalid email '#{email_address}' of customer" }, status: :unprocessable_entity
        return
      end
      local_customer = User.find_by(email: email_address.downcase)
      if !local_customer
        role_ids = Role.signup_role_ids
        local_customer = User.create(
          firstname: '',
          lastname:  '',
          email:     email_address,
          password:  '',
          active:    true,
          role_ids:  role_ids,
        )
      end
      clean_params[:customer_id] = local_customer.id
    end

    # try to create customer if needed
    if clean_params[:customer_id].blank? && customer.present?
      check_attributes_by_current_user_permission(customer)
      clean_customer = User.association_name_to_id_convert(customer)
      local_customer = nil
      if !local_customer && clean_customer[:id].present?
        local_customer = User.find_by(id: clean_customer[:id])
      end
      if !local_customer && clean_customer[:email].present?
        local_customer = User.find_by(email: clean_customer[:email].downcase)
      end
      if !local_customer && clean_customer[:login].present?
        local_customer = User.find_by(login: clean_customer[:login].downcase)
      end
      if !local_customer
        role_ids = Role.signup_role_ids
        local_customer = User.new(clean_customer)
        local_customer.role_ids = role_ids
        local_customer.save!
      end
      clean_params[:customer_id] = local_customer.id
    end

    clean_params = Ticket.param_cleanup(clean_params, true)
    ticket = Ticket.new(clean_params)

    # check if article is given
    if !params[:article]
      render json: { error: 'article hash is missing' }, status: :unprocessable_entity
      return
    end

    # create ticket
    ticket.remedy_id = params[:remedy_id]
    ticket.save!
    ticket.with_lock do

      # create tags if given
      if params[:tags].present?
        tags = params[:tags].split(/,/)
        tags.each do |tag|
          ticket.tag_add(tag)
        end
      end

      # create article if given
      if params[:article]
        article_create(ticket, params[:article])
      end
    end
    # create links (e. g. in case of ticket split)
    # links: {
    #   Ticket: {
    #     parent: [ticket_id1, ticket_id2, ...]
    #     normal: [ticket_id1, ticket_id2, ...]
    #     child: [ticket_id1, ticket_id2, ...]
    #   },
    # }
    if params[:links].present?
      link = params[:links].permit!.to_h
      raise Exceptions::UnprocessableEntity, 'Invalid link structure' if !link.is_a? Hash

      link.each do |target_object, link_types_with_object_ids|
        raise Exceptions::UnprocessableEntity, 'Invalid link structure (Object)' if !link_types_with_object_ids.is_a? Hash

        link_types_with_object_ids.each do |link_type, object_ids|
          raise Exceptions::UnprocessableEntity, 'Invalid link structure (Object->LinkType)' if !object_ids.is_a? Array

          object_ids.each do |local_object_id|
            link = Link.add(
              link_type:                link_type,
              link_object_target:       target_object,
              link_object_target_value: local_object_id,
              link_object_source:       'Ticket',
              link_object_source_value: ticket.id,
            )
          end
        end
      end
    end

    if response_expand?
      result = ticket.reload.attributes_with_association_names
      render json: result, status: :created
      return
    end

    if response_full?
      full = Ticket.full(ticket.id)
      render json: full, status: :created
      return
    end

    if response_all?
      render json: ticket_all(ticket.reload), status: :created
      return
    end

    render json: ticket.reload.attributes_with_association_ids, status: :created
  end

  def triples
    return if !params[:level_1].present? || !params[:level_2].present?
    categorization = TicketCategorization.find_by(level_1: params[:level_1], level_2: params[:level_2])
    return if !categorization
    mapping = RemedyTripleMapping.find_by(ticket_categorization_id: categorization[:id])
    return if !mapping
    triple = RemedyTriple.find_by(id: mapping[:remedy_triple_id])
    return if !triple
    render json: {level_1:triple[:level_1], level_2:triple[:level_2], level_3:triple[:level_3]}
  end

  def categorizations
    return if !params[:level_1].present? || !params[:level_2].present? || !params[:level_3].present?
    triple = RemedyTriple.find_by(level_1: params[:level_1], level_2: params[:level_2], level_3: params[:level_3])
    return if !triple
    mapping = RemedyTripleMapping.find_by(remedy_triple_id: triple[:id])
    return if !mapping
    categorization = TicketCategorization.find_by(id: mapping[:ticket_categorization_id])
    return if !categorization
    render json: {level_1:categorization[:level_1], level_2:categorization[:level_2]}
  end

 end

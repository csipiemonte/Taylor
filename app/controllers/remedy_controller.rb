class RemedyController < ApplicationController

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

 end

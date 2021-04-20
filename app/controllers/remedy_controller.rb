class RemedyController < ApplicationController
  include CreatesTicketArticles
  include ClonesTicketArticleAttachments
  include ChecksUserAttributesByCurrentUserPermission
  include TicketStats

  prepend_before_action { authentication_check && authorize! }

  # GET /api/v1/remedy_tickets
    def migrating
      remedy_agent = User.find_by(login:'remedy.agent@zammad.org')
      tickets = Ticket.where("tickets.remedy_id IS NULL") #AND tickets.owner_id = #{remedy_agent[:id]}"
      render json: tickets
    end

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

  def states
    render json: Setting.get('remedy_ticket_state_mapping')
  end

  def triple
    return if !params[:level_1].present? || !params[:level_2].present?
    categorization = TicketCategorization.find_by(level_1: params[:level_1], level_2: params[:level_2])
    return if !categorization
    mapping = RemedyTripleMapping.find_by(ticket_categorization_id: categorization[:id])
    return if !mapping
    triple = RemedyTriple.find_by(id: mapping[:remedy_triple_id])
    return if !triple
    render json: {level_1:triple[:level_1], level_2:triple[:level_2], level_3:triple[:level_3]}
  end

  def categorization
    return if !params[:level_1].present? || !params[:level_2].present? || !params[:level_3].present?
    triple = RemedyTriple.find_by(level_1: params[:level_1], level_2: params[:level_2], level_3: params[:level_3])
    return if !triple
    mapping = RemedyTripleMapping.find_by(remedy_triple_id: triple[:id])
    return if !mapping
    categorization = TicketCategorization.find_by(id: mapping[:ticket_categorization_id])
    return if !categorization
    render json: {level_1:categorization[:level_1], level_2:categorization[:level_2]}
  end

  def triples_table
    render json: RemedyTripleMapping.joins(:remedy_triple,:ticket_categorization)
  end

  def priorities
    priorities = Setting.get('remedy_ticket_priority_mapping')
    result = {}
    priorities.each do |index,priority|
      values = priority.split('-')
      Rails.logger.info "priority: #{values}"
      result["#{index}"] = {
        impatto:values[0],
        urgenza:values[1]
      }
    end
    render json: result
  end

  def settings
    render json: {
      remedy_enabled: integration_status,
      state_alignment: state_alignment,
      remedy_coordinates: keys
    }
  end

  def most_recent_state
  return if !params[:compare]
    Rails.logger.info "PARAMS #{params}"
    highest_value = 0
    highest_key = ""
    params[:compare].each do |key,value|
      return if !value.is_a? Integer
      state = Ticket::State.find_by(id: value)
      return if !state
      if state[:state_type_id] > highest_value
        highest_key = key
        highest_value = value
      end
    end
    render json: {key:highest_key,value:highest_value}
  end

  private

  def integration_status
    Setting.get('remedy_integration')
  end

  def state_alignment
    Setting.get('remedy_state_alignment')
  end

  def keys
    base_url = Setting.get('remedy_base_url')
    token = Setting.get('remedy_token')
    {base_url:base_url, token:token, }
  end
end

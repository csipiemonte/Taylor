class Api::Nextcrm::V1::TicketsController < ::TicketsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index
    super
    # puts JSON.parse(response.body).first.to_yaml.gsub("\n-", "\n\n-")
  end

  def search
    params[:expand] = true
    if params[:filter]
      filter = JSON.parse(params[:filter])
      query = filterToElasticSearchQuery(filter)
      params[:query] = query
    end
    super
  end

  def show
    super
  end

  def create
    if params[:article] and not params[:article][:type_id]
      raise Exceptions::UnprocessableEntity, "Need at least article: { type_id: \"<id>\" "
    end
    if params[:ticket] and params[:ticket][:customer_id]
      params[:ticket][:customer_id] = "guess:#{params[:ticket][:customer_id]}"
    end
    super
  end

  def update
    
    if params[:ticket] and params[:ticket][:customer_id]
      params[:ticket][:customer_id] = "guess:#{params[:ticket][:customer_id]}"
    end
    super
  end


  private

  def filterToElasticSearchQuery(filter)
    ret_query = ""
    attributes = filter.keys
    attributes.each do |att|
      operator = filter[att].keys[0]
      value = filter[att][operator] 
      case operator
        when "eq"
          ret_query += "#{att}:#{value} AND "
        when "ci"
          ret_query += "#{att}:*#{value}* AND "
        when "si"
          ret_query += "#{att}:#{value}* AND "
        when "ei"
          ret_query += "#{att}:*#{value} AND "
        else
          next
      end
    end
    ret_query.strip!.delete_suffix!("AND")
    return ret_query
  end


end
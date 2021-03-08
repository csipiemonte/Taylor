class Api::Nextcrm::V1::TicketsController < ::TicketsController
  include Api::Nextcrm::V1::Concerns::ReadesApiManagerJwt

  def index
    
    super
    # puts JSON.parse(response.body).first.to_yaml.gsub("\n-", "\n\n-")
  end

  def show
    super
  end

  def create
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


end
class ExternalActivityController < ApplicationController

  prepend_before_action { authentication_check && authorize! }


  def index_external_activity
    if params[:ticket_id]
      render json: ExternalActivity.where(
        external_ticketing_system_id:params[:ticketing_system_id],
        ticket_id:params[:ticket_id]
      )
    else
      render json: ExternalActivity.where(external_ticketing_system_id:params[:ticketing_system_id])
    end
  end

  def show_external_activity
    render json: ExternalActivity.find_by(id: params[:id])
  end

  def create_external_activity
    return if not params[:ticketing_system_id]
    return if not params[:ticket_id]
    external_activity = ExternalActivity.create(
      external_ticketing_system_id: params[:ticketing_system_id],
      ticket_id: params[:ticket_id],
      data: {value: params[:data]},
      bidirectional_alignment: params[:bidirectional_alignment]
    )
    external_activity.save!
    render json: external_activity
  end

  def index_external_ticketing_system
    render json: ExternalTicketingSystem.all
  end

  def show_external_ticketing_system
    render json: ExternalTicketingSystem.find_by(id: params[:id])
  end

end

class ExternalActivity < ApplicationModel
  belongs_to :ticket
  belongs_to :external_ticketing_system
  after_update  :check_needs_attention
  store :data

  def check_needs_attention
    ticket = self.ticket
    if saved_change_to_attribute?(:needs_attention)==true
      ticket.needs_attention = true
      ticket.save!
    elsif saved_change_to_attribute?(:needs_attention)==false
      ExternalActivity.where(ticket_id: ticket.id).each do |activity|
        return if activity.needs_attention==true
      end
      ticket.needs_attention = false
      ticket.save!
    end
  end

end

class ExternalActivity < ApplicationModel
  belongs_to :ticket
  belongs_to :external_ticketing_system
  after_update  :check_needs_attention
  store :data

  def check_needs_attention

    if saved_change_to_needs_attention?  # e'cambiato needs_attention?
      ticket = self.ticket
      needs_attention_new_value = saved_changes["needs_attention"][1]
      if needs_attention_new_value==true or needs_attention_new_value=="true"
        ticket.needs_attention = true
        ticket.save!
      else
        ExternalActivity.where(ticket_id: ticket.id).each do |activity|
          return if activity.needs_attention==true
        end
        ticket.needs_attention = false
        ticket.save!
      end
    end
    
  end

end

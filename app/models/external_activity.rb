class ExternalActivity < ApplicationModel
  belongs_to :ticket
  belongs_to :external_ticketing_system
  after_update :check_needs_attention
  store :data

  def check_needs_attention
    # 'saved_change_to_attributename?': If the attribute was changed,
    # the result will be an array containing the original value and the saved value.
    if saved_change_to_needs_attention?
      ticket = self.ticket
      needs_attention_new_value = saved_changes['needs_attention'][1]

      if needs_attention_new_value == true || needs_attention_new_value == 'true'
        ticket.needs_attention = true
      else
        # TODO, a cosa serve questo loop sotto?
        ExternalActivity.where(ticket_id: ticket.id).each do |activity|
          return if activity.needs_attention == true
        end
        ticket.needs_attention = false
      end
      ticket.save!
    end
  end


    # motodi di log / debug
    def getFilteredData
      return_hash =  Marshal.load(Marshal.dump(self.data))
  
  
      return_hash["commento"].each do |c|
        if c["attachments"] 
          c["attachments"].keys.each do |key|
            c["attachments"][key]["file"] = "[FILTERED]"
          end
        end
      end
  
      return return_hash
    end

    
end

# Copyright (C) 2012-2016 Zammad Foundation, http://zammad-foundation.org/

class VirtualAgentTicketsController < TicketsController

  prepend_before_action { authentication_check && authorize! }

  def index
    super
    visibility = Setting.find_by(name:'external_activity_public_visibility').state_current[:value]
    # optimized json parse
    obj_resp = Oj.load(response.body)
    if obj_resp.is_a? Array
      obj_resp.each do |ticket|
        include_external_activities visibility, ticket
      end
    else
      include_external_activities visibility, obj_resp
    end
    str_resp = Oj.dump(obj_resp)
    response.body = str_resp
  end

  def show
    super
    visibility = Setting.find_by(name:'external_activity_public_visibility').state_current[:value]
    ticket = Oj.load(response.body)
    include_external_activities visibility, ticket
    str_resp = Oj.dump(ticket)
    response.body = str_resp
  end

  private

  def include_external_activities (visibility,ticket)
    ticket["external_activities"] = {}
    ExternalTicketingSystem.all.each do |system|
      if visibility[system.name]["virtual_agent_"+current_user.id.to_s] == true
        activities = []
        ExternalActivity.where(ticket_id:ticket["id"]).each do |activity|
          nested_activity = {}
          system.model.each do |key,field|
            Rails.logger.info "field #{field}"
            if field["external_visibility"] == true
              nested_activity[field["name"]] = activity.data[field["name"]]
            end
          end
          activities.append nested_activity
        end
        ticket["external_activities"][system.name] = activities
      end
    end
  end

end

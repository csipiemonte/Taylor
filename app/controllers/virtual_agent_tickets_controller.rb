# Copyright (C) 2021 CSI Piemonte, https://www.csipiemonte.it/

# Controller custom CSI Piemonte che estende il controller TicketsController
# e per i metodi 'index', 'search', 'show' aggiunge i dati inerenti le external activities,
# qualora ci siano le abilitazioni attive
# cfr: https://gitlab.csi.it/prodotti/nextcrm/zammad/issues/145
class VirtualAgentTicketsController < TicketsController

  before_action :authorize!

  def index
    super
    extend_response response
  end

  def search
    super
    extend_response response
  end

  def show
    super
    extend_response response
  end

  private

  def extend_response (response)
    visibility = Setting.find_by(name: 'external_activity_public_visibility').state_current[:value]
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

  def include_external_activities (visibility, ticket)
    # 'visibility' e' un hash con il nome dell'external ticketing system nella chiave e una hash nel valore.
    # La hash del valore e' composta da tante entry cosi' composte:
    # virtual_agent_<id>: <true/false>
    # dove 'virtual_agent_' e' una stringa fissa, <id> e' l'ID del current user, <true/false> se e' abilitato o meno
    # a vedere i dati delle external activities.
    ticket['external_activities'] = {}
    ExternalTicketingSystem.all.each do |system|
      next unless visibility[system.name]
      next if visibility[system.name]['virtual_agent_' + current_user.id.to_s] == false

      activities = []
      ExternalActivity.where(external_ticketing_system_id: system.id, ticket_id: ticket['id']).each do |activity|
        nested_activity = {}

        # system.model e' un hash
        system.model.each_value do |field|
          Rails.logger.info "field #{field}"
          if field['external_visibility'] == true
            nested_activity[field['name']] = activity.data[field['name']]
          end
        end
        activities.append nested_activity
      end
      ticket['external_activities'][system.name] = activities
    end
  end

end

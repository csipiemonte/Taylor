# Customer data platform

class UserCdpEventsController < ApplicationController
  prepend_before_action { authentication_check && authorize! }

  def index
    user = User.find(params[:id])
    # authorize!(user)

    # return_obj = [
    #   {
    #     id:1,
    #     user_id: user.id,
    #     scope: 'sanità',
    #     name: 'prenotazione esame',
    #     created_at: Time.now - 5.minutes
    #   },
    #   {
    #     id:1,
    #     user_id: user.id,
    #     scope: 'sanità',
    #     name: 'appuntamento medico',
    #     created_at: Time.now - 3.minutes
    #   },
    #   {
    #     id:3,
    #     user_id: user.id,
    #     scope: 'sanità',
    #     name: 'ritiro referti',
    #     created_at: Time.now - 1.minutes
    #   },
    # ]

    unomi_profile = CustomerDataPlatformService.fetch_profile(user.email)
    unomi_profile_id = unomi_profile ? unomi_profile['itemId'] : nil 

    unless unomi_profile_id
      render json: {:error => "unomi user profile not found for email #{user.email}"},  status: 404
      return 
    end

    unomi_events = CustomerDataPlatformService.search_events(unomi_profile_id)
    
    scope_data = {}


   
    events = []
    total_events = 0
    unomi_events_list = unomi_events['list']
    unomi_events_list.each do |e|
      scope = e['scope']

      #next unless [ 'Agricoltura'].include? scope
      #next unless [ 'Feedback'].include? e['eventType']
      next unless ['Sanità', 'Tributi', 'Agricoltura'].include? scope
      

      total_events += 1

      
      target = nil 
      if e['target']
        target = e['target']['itemType']
      end

      this_event =  {
        id: e['itemId'],
        scope: scope,
        type: e['eventType'],
        created_at: e['timeStamp'],
        properties: {
          description: e['properties'] ? e['properties']['description'] : ''
        },
        source: {
          type: e['source']['itemType'],
          properties: {
            name: e['source']['properties'] ? e['source']['properties']['name'] : ''
          }
        },
        target: target,

      }

      scope_data[scope] ||= {}
      scope_data[scope]['count'] ||= 0
      scope_data[scope]['count'] += 1

      if e['eventType'].downcase.include?('feedback') && e['properties']['NPS_score']
        scope_data[scope]['NPS_scores'] ||= []
        nps_score = e['properties']['NPS_score']
        scope_data[scope]['NPS_scores'] << nps_score.to_f if nps_score
        this_event[:properties]['NPS_score'] = nps_score.to_f if nps_score
      end

      events << this_event
    end


    global_nps_score_array = []
    charts_data = {
      scope_usage: {
        data: [],
        labels: []
      },
      scope_nps: {
        data: [],
        labels: []
      }
    }
    scope_data.keys.each do |k|
      next unless scope_data[k]['NPS_scores']
      a = scope_data[k]['NPS_scores']
      scope_data[k]['NPS_mean'] = (a.sum(0.0) / a.size).round(1) 
      global_nps_score_array << scope_data[k]['NPS_mean']
      charts_data[:scope_usage][:data] << ((scope_data[k]['count'].to_f / total_events) * 100.0).round(1)
      charts_data[:scope_usage][:labels] << k
      charts_data[:scope_nps][:data] << scope_data[k]['NPS_mean']
      charts_data[:scope_nps][:labels] << k
    end

    global_nps_score = (global_nps_score_array.sum(0.0) / global_nps_score_array.size).round(1) 

 
    events.sort_by!{ |k| k[:created_at]}
    events.reverse!

    unomi = {
      profile_id: unomi_profile_id
    }

    render json: {unomi:unomi, data: events, scope_data:scope_data, global_nps_score:global_nps_score, charts_data: charts_data}, status: :ok
  end

  # def show
  #   model_show_render(Trigger, params)
  # end

end

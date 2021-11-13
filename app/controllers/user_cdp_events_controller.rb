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
    return [] unless unomi_profile_id
    unomi_events = CustomerDataPlatformService.search_events(unomi_profile_id)

    events = unomi_events.map do |e|
      {
        id: e['idemId'],
        scope: e['scope'],
        name: e['eventType'],
        created_at: e['timeStamp'],
      }
    end

    events.sort_by!{ |k| k[:created_at]}
    events.reverse!

    render json: events, status: :ok
  end

  # def show
  #   model_show_render(Trigger, params)
  # end

end

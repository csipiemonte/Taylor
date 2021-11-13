class App.UserCdp extends App.Controller
  constructor: (params) ->
    super

    # check authentication
    @authenticateCheckRedirect()

    # fetch new data if needed
    App.User.full(@user_id, @render)

  meta: =>
    meta =
      url: @url()
      id:  @user_id

    if App.User.exists(@user_id)
      user = App.User.find(@user_id)

      meta.head       = user.displayName()
      meta.title      = user.displayName()
      meta.iconClass  = user.icon()
    meta

  url: =>
    '#user/cdp/' + @user_id

  show: =>
    App.OnlineNotification.seen('User', @user_id)
    @navupdate(url: '#', type: 'menu')

  changed: ->
    false



  render: (user) =>

    if !@doNotLog
      @doNotLog = 1
      @recentView('User', @user_id)

    elLocal = $(App.view('user_cdp/index')(
      user: user
    ))

    new User(
      object_id: user.id
      el: elLocal.find('.js-profileName')
    )

    new CdpEvents(
      user_id: user.id
      el:   elLocal.find('.js-cdp-events')
    )


    @html elLocal

    new App.UpdateTastbar(
      genericObject: user
    )

  setPosition: (position) =>
    @$('.profile').scrollTop(position)

  currentPosition: =>
    @$('.profile').scrollTop()

class User extends App.ObserverController
  model: 'User'
  observe:
    firstname: true
    lastname: true
    organization_id: true
    image: true

  render: (user) =>
    if user.organization_id
      new Organization(
        object_id: user.organization_id
        el: @el.siblings('.js-organization')
      )

    @html App.view('user_cdp/name')(
      user: user
    )

class CdpEvents extends App.Controller
  events:
    'click .js-record': 'show'

  constructor: ->
    super
    @fetch()
    @records = []

  show: (e) =>
    e.preventDefault()

  fetch: =>
    @ajax(
      id:   "cdp_events_#{@user_id}"
      type: 'GET'
      url:  "#{@apiPath}/users/#{@user_id}/cdp_events"
      data:
        limit: @limit || 50
      processData: true
      success: (data) =>
        
        @records = data
        @render()
    )

  render: =>
    @html App.view('user_cdp/cdp_events')(
      records: @records
    )

class Router extends App.ControllerPermanent
  requiredPermission: 'ticket.agent'
  constructor: (params) ->
    super

    # cleanup params
    clean_params =
      user_id:  params.user_id

    App.TaskManager.execute(
      key:        "User-#{@user_id}"
      controller: 'UserCdp'
      params:     clean_params
      show:       true
    )

App.Config.set('user/cdp/:user_id', Router, 'Routes')

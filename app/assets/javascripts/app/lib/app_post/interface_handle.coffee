class App.Run extends App.Controller
  constructor: ->
    super
    @el = $('#app')

    App.Event.trigger('app:init')

    # browser check
    return if !App.Browser.check()

    # hide splash screen
    $('.splash').hide()

    # init collections
    App.Collection.init()

    # check if session already exists/try to get session data from server
    App.Auth.loginCheck(@start)

  start: =>
    # create web socket connection
    App.WebSocket.connect()

    ### feature toggle ###
    # per rimozione elemnti da navbar principale
    navbarItems = App.Config.get('NavBar')
    # per rimozione system /  integrations prima che vengano utilizzate dal controller che gestisce il menu navigazione delle integrations ( Integrations extends App.ControllerSubContent )
    integrationItems = App.Config.get('NavBarIntegrations')
    # per rimozione elemnti da navbar secondaria admin (es. channels) prima che vengano utilizzati dal controller che gestisce il menu admin di navigazione ( App.ControllerNavSidebar )
    groups = App.Config.get('NavBarAdmin')
    if App.Feature.isDisabled('chat')
      delete navbarItems.ChatMonitor 
      delete navbarItems.CustomerChat 
      delete groups.Chat
      console.debug('[feature toggle] rimossi elementi chat da main nav, admin nav')
    if App.Feature.isDisabled('telegram')
      delete groups.Telegram 
      console.debug('[feature toggle] rimossi elementi telegram da nav admin')
    if App.Feature.isDisabled('external_activity')
      delete integrationItems.IntegrationZammadLight
      delete integrationItems.IntegrationRemedy
      console.debug('[feature toggle] rimossi elementi external activity da nav system/integrations')

    # init plugins
    App.Plugin.init(@el)

    # init routes
    App.Router.init(@el)

    # start frontend time update
    @frontendTimeUpdate()

    # bind to fill selected text into
    App.ClipBoard.bind(@el)

    App.Event.trigger('app:ready')

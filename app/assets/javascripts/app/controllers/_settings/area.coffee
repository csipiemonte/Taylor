class App.SettingsArea extends App.Controller
  constructor: ->
    super

    # check authentication
    @authenticateCheckRedirect()

    App.Setting.fetchFull(
      @render
      force: false
    )

  render: =>

    # search area settings
    settings = App.Setting.search(
      filter:
        area: @area
    )
  
    # feature toggle elimino i setting non abilitati dalle voci di menu
    if App.Feature.isDisabled("external_activity")
      settings = settings.filter((s) -> s.name != "auth_advanced_saml")
      console.debug("[feature toggle] auth_advanced_saml setting disabled ")
    if App.Feature.isDisabled("chat_bot")
      settings = settings.filter((s) -> s.name != "chat_bot_api_settings")
      console.debug("[feature toggle] chat_bot setting disabled ")
      
      

    # filter online service settings
    if App.Config.get('system_online_service')
      settings = _.filter(settings, (setting) ->
        return if setting.online_service
        return if setting.preferences && setting.preferences.online_service_disable
        setting
      )
      return if _.isEmpty(settings)

    # filter disabled settings
    settings = _.filter(settings, (setting) ->
      return if setting.preferences && setting.preferences.disabled
      setting
    )

    # sort by prio
    settings = _.sortBy( settings, (setting) ->
      return if !setting.preferences
      setting.preferences.prio
    )

    elements = []
    for setting in settings
      if setting.preferences.hidden isnt true
        if setting.preferences.controller && App[setting.preferences.controller]
          item = new App[setting.preferences.controller](setting: setting)
        else
          item = new App.SettingsAreaItem(setting: setting)
        elements.push item.el

    @html elements

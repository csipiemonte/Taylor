class App.ChatMonitor extends App.Controller

  constructor: ->
    super
    @render()

  render: ->
    if !@permissionCheck('chat.supervisor')
      @renderScreenUnauthorized(objectName: 'Chat')
      return

    @html App.view('chat_monitor/index')()

class ChatMonitorRouter extends App.ControllerPermanent
  requiredPermission: 'chat.supervisor'
  constructor: (params) ->
    super

    # cleanup params
    clean_params =
      session_id: params.session_id

    App.TaskManager.execute(
      key:        'ChatMonitor'
      controller: 'ChatMonitor'
      params:     clean_params
      show:       true
      persistent: true
    )

App.Config.set('chat_monitor', ChatMonitorRouter, 'Routes')
App.Config.set('chat_monitor/session/:session_id', ChatMonitorRouter, 'Routes')
App.Config.set('ChatMonitor', { controller: 'ChatMonitor', permission: ['chat.supervisor'] }, 'permanentTask')
App.Config.set('ChatMonitor', { prio: 1300, parent: '', name: 'Chat Monitor', target: '#chat_monitor', key: 'ChatMonitor', shown: true, permission: ['chat.supervisor'], class: 'eye' }, 'NavBar')

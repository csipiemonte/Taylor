class App.ChatMonitor extends App.Controller

  elements:
    '.chat-workspace':            'workspace'

  constructor: ->
    super
    @render()

  render: ->
    if !@permissionCheck('chat.supervisor')
      @renderScreenUnauthorized(objectName: 'Chat')
      return

    @html App.view('chat_monitor/index')()

    list = App.ChatSession.all()
    console.log(list)

    @workspace.html('')
    @table = new App.ControllerTable(
      tableId:  "chat-monitoring-table"
      el:       @workspace
      overview: @columns || [ 'id', 'user_id', 'state', 'stop_chatbot', 'created_at' ]
      model:    App.ChatSession
      objects:  list
      #bindRow:
      #  events:
      #    'click': openTicket
      callbackHeader: null
      callbackAttributes: null
      radio: true
    )
    @table.show()

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

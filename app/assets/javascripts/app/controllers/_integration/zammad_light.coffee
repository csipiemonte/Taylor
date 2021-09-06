class Index extends App.ControllerIntegrationBase
  featureIntegration: 'asl_integration'
  featureName: 'ASL'
  featureConfig: 'asl_integration'
  description: [
    ['This service forwards tickets to a ASL instance.']
  ]

  render: =>
    super
    new Form(
      el: @$('.js-form')
    )

class Form extends App.Controller
  events:
    'submit form': 'update'

  constructor: ->
    super
    @render()


  render: =>
    @ajax(
      id:    'virtual_agents'
      type:  'GET'
      url:   "#{@apiPath}/virtual_agents"
      success: (data) =>
        @virtual_agents = data
        @html App.view('integration/zammad_light')(
          groups: App.Group.all()
          virtual_agents: @virtual_agents
          visibility : App.Setting.get('external_activity_public_visibility')
          group_access : App.Setting.get('external_activity_group_access')
          asl_base_url: App.Setting.get('asl_base_url')
          asl_token: App.Setting.get('asl_token')
          asl_state_alignment: App.Setting.get('asl_state_alignment')
        )
        @groupTableHandlers()
    )

  groupTableHandlers: () =>
    App.Group.all().forEach (group) ->
      $('#zammad_light_read_write_for_'+group.id).click ->
        $('#zammad_light_read_only_for_'+group.id).prop("checked", false)
      $('#zammad_light_read_only_for_'+group.id).click ->
        $('#zammad_light_read_write_for_'+group.id).prop("checked", false)

  update: (e) =>
    e.preventDefault()
    state_alignment = $('#asl_state_alignment').prop('checked')
    base_url = $('#asl_base_url').val()
    token = $('#asl_token').val()
    visibility = App.Setting.get('external_activity_public_visibility')
    if !visibility["ASL"]
      visibility["ASL"] = {}
    @virtual_agents.forEach (virtual_agent) ->
      if $('#zammad_light_visibility_for_'+virtual_agent.id+':checkbox:checked').length > 0
        visibility["ASL"]["virtual_agent_"+virtual_agent.id] = true
      else
        visibility["ASL"]["virtual_agent_"+virtual_agent.id] = false
    visibility = App.Setting.set('external_activity_public_visibility',visibility)

    group_access = App.Setting.get('external_activity_group_access')
    if !group_access["ASL"]
      group_access["ASL"] = {}
    App.Group.all().forEach (group) ->
      if $('#zammad_light_read_write_for_'+group.id+':checkbox:checked').length > 0
        group_access["ASL"]["group_"+group.id] = "rw"
      else if $('#zammad_light_read_only_for_'+group.id+':checkbox:checked').length > 0
        group_access["ASL"]["group_"+group.id] = "r"
      else
        group_access["ASL"]["group_"+group.id] = null
    App.Setting.set('external_activity_group_access', group_access)

    App.Setting.set('asl_state_alignment', state_alignment)
    App.Setting.set('asl_base_url', base_url)
    App.Setting.set('asl_token', token, {notify: true})

class State
  @current: ->
    App.Setting.get('asl_integration')

App.Config.set(
  'IntegrationZammadLight'
  {
    name: 'ASL'
    target: '#system/integration/zammad_light'
    description: 'An external ticket-handling service.'
    controller: Index
    state: State
    permission: ['admin.integration.zammad_light']
  }
  'NavBarIntegrations'
)

class Index extends App.ControllerIntegrationBase
  featureIntegration: 'remedy_integration'
  featureName: 'Remedy'
  featureConfig: 'remedy_integration'
  description: [
    ['This service forwards tickets to Remedy. Since tickets can be also updated Remedy-side, a ticket aligning system should be provided.']
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
        @html App.view('integration/remedy')(
          groups: App.Group.all()
          virtual_agents: @virtual_agents
          visibility : App.Setting.get('external_activity_public_visibility')
          group_access : App.Setting.get('external_activity_group_access')
          remedy_base_url: App.Setting.get('remedy_base_url')
          remedy_token: App.Setting.get('remedy_token')
          remedy_state_alignment: App.Setting.get('remedy_state_alignment')
        )
        @groupTableHandlers()
    )

  groupTableHandlers: () =>
    App.Group.all().forEach (group) ->
      $('#remedy_read_write_for_'+group.id).click ->
        $('#remedy_read_only_for_'+group.id).prop("checked", false)
      $('#remedy_read_only_for_'+group.id).click ->
        $('#remedy_read_write_for_'+group.id).prop("checked", false)

  update: (e) =>
    e.preventDefault()
    state_alignment = $('#remedy_state_alignment').prop('checked')
    base_url = $('#remedy_base_url').val()
    token = $('#remedy_token').val()
    visibility = App.Setting.get('external_activity_public_visibility')
    if !visibility["Remedy"]
      visibility["Remedy"] = {}
    @virtual_agents.forEach (virtual_agent) ->
      if $('#remedy_visibility_for_'+virtual_agent.id+':checkbox:checked').length > 0
        visibility["Remedy"]["virtual_agent_"+virtual_agent.id] = true
      else
        visibility["Remedy"]["virtual_agent_"+virtual_agent.id] = false
    visibility = App.Setting.set('external_activity_public_visibility',visibility)

    group_access = App.Setting.get('external_activity_group_access')
    if !group_access["Remedy"]
      group_access["Remedy"] = {}
    App.Group.all().forEach (group) ->
      if $('#remedy_read_write_for_'+group.id+':checkbox:checked').length > 0
        group_access["Remedy"]["group_"+group.id] = "rw"
      else if $('#remedy_read_only_for_'+group.id+':checkbox:checked').length > 0
        group_access["Remedy"]["group_"+group.id] = "r"
      else
        group_access["Remedy"]["group_"+group.id] = null
    App.Setting.set('external_activity_group_access', group_access)

    App.Setting.set('remedy_state_alignment', state_alignment)
    App.Setting.set('remedy_base_url', base_url)
    App.Setting.set('remedy_token', token, {notify: true})

class State
  @current: ->
    App.Setting.get('remedy_integration')

App.Config.set(
  'IntegrationRemedy'
  {
    name: 'Remedy'
    target: '#system/integration/remedy'
    description: 'An external ticket-handling service.'
    controller: Index
    state: State
    permission: ['admin.integration.remedy']
  }
  'NavBarIntegrations'
)

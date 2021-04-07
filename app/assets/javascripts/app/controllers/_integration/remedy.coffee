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
    @html App.view('integration/remedy')(
      remedy_base_url: App.Setting.get('remedy_base_url')
      remedy_token: App.Setting.get('remedy_token')
      remedy_state_alignment: App.Setting.get('remedy_state_alignment')
    )


  update: (e) =>
    e.preventDefault()
    state_alignment = $('#remedy_state_alignment').prop('checked')
    base_url = $('#remedy_base_url').val()
    token = $('#remedy_token').val()
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

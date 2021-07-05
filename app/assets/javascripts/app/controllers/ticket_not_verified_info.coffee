class App.TicketNotVerifiedInfo extends App.ControllerModal
  buttonClose: true
  buttonCancel: false
  buttonSubmit: false
  head: 'Not verified customer\'s information'
  shown: false

  constructor: ->
    super
    @render()

  content: =>
    content = $( App.view('ticket_zoom/not_verified_info_modal')(
      object:          @object
    ))
    content


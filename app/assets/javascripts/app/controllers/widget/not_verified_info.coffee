class App.WidgetNotVerifiedInfo extends App.WidgetLink
  @registerPopovers 'Ticket'

  render: =>
    @html App.view('ticket_zoom/not_verified_info')()
    @renderPopovers()

  add: (e) =>
    e.preventDefault()
    new App.TicketNotVerifiedInfo(
      object:         @object
      parent:         @
      container:      @el.closest('.content')
    )

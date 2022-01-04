class Edit extends App.ObserverController
  model: 'Ticket'
  observeNot:
    created_at: true
    updated_at: true
  globalRerender: false

  render: (ticket, diff) =>
    defaults = ticket.attributes()
    delete defaults.article # ignore article infos
    followUpPossible = App.Group.find(defaults.group_id).follow_up_possible
    ticketState = App.TicketState.find(defaults.state_id).name

    taskState = @taskGet('ticket')
    handlers = @Config.get('TicketZoomFormHandler')

    if !_.isEmpty(taskState)
      defaults = _.extend(defaults, taskState)

    # CSI custom: get subitems to perform prefiltering
    subItems = App.ServiceCatalogSubItem.select (item) -> item.parent_service == defaults.service_catalog_item_id
    @formMeta.filter['service_catalog_sub_item_id'] = (item.id for item in subItems)

    if followUpPossible == 'new_ticket' && ticketState != 'closed' ||
       followUpPossible != 'new_ticket' ||
       @permissionCheck('admin') || @permissionCheck('ticket.agent')
      new App.ControllerForm(
        elReplace:      @el
        model:          App.Ticket
        screen:         'edit'
        handlersConfig: handlers
        filter:         @formMeta.filter
        formMeta:       @formMeta
        params:         defaults
        isDisabled:     !ticket.editable()
        taskKey:        @taskKey
        events:
          "change [name='service_catalog_item_id']": => @filter_service_catalog_sub_items()
        #bookmarkable:  true
      )
    else
      new App.ControllerForm(
        elReplace:      @el
        model:          App.Ticket
        screen:         'edit'
        handlersConfig: handlers
        filter:         @formMeta.filter
        formMeta:       @formMeta
        params:         defaults
        isDisabled:     ticket.editable()
        taskKey:        @taskKey
        #bookmarkable:  true
      )

    @markForm(true)

    return if @resetBind
    @resetBind = true
    @bind('ui::ticket::taskReset', (data) =>
      return if data.ticket_id.toString() isnt ticket.id.toString()
      @render(ticket)
    )

  # CSI custom: filter service_catalog_sub_items based on service_catalog_item
  filter_service_catalog_sub_items: ->
    catalog_item = $("[name='service_catalog_item_id']")
    catalog_sub_item = $("[name='service_catalog_sub_item_id']")

    selected_item = catalog_item.val()
    if !selected_item
      return
    selected_item = Number(selected_item)

    catalog_sub_item.empty()
    subItems = (item for item in App.ServiceCatalogSubItem.all() when item.parent_service == selected_item)
    subItems.forEach (option) ->
      o = new Option(option['name'], option['id'])
      $(o).html(option['name'])
      catalog_sub_item.append(o)
    
class SidebarTicket extends App.Controller
  constructor: ->
    super
    @bind 'config_update_local', (data) => @configUpdated(data)

  configUpdated: (data) ->
    if data.name != 'kb_active'
      return

    if data.value
      return

    @editTicket(@el)

  sidebarItem: =>
    @item = {
      name: 'ticket'
      badgeIcon: 'message'
      sidebarHead: 'Ticket'
      sidebarCallback: @editTicket
    }
    if @permissionCheck('ticket.agent')
      @item.sidebarActions = [
        {
          title:    'History'
          name:     'ticket-history'
          callback: @showTicketHistory
        },
        {
          title:    'Merge'
          name:     'ticket-merge'
          callback: @showTicketMerge
        },
        {
          title:    'Change Customer'
          name:     'customer-change'
          callback: @changeCustomer
        },
      ]
    @item

  reload: (args) =>

    # apply tag changes
    if @tagWidget
      if args.tags
        @tagWidget.reload(args.tags)
      if args.tagAdd
        @tagWidget.add(args.tagAdd, args.source)
      if args.tagRemove
        @tagWidget.remove(args.tagRemove)

    # apply link changes
    if @linkWidget && args.links
      @linkWidget.reload(args.links)

    if @linkKbAnswerWidget && args.links
      @linkKbAnswerWidget.reload(args.links)

  editTicket: (el) =>
    @el = el
    localEl = $(App.view('ticket_zoom/sidebar_ticket')())

    @edit = new Edit(
      object_id: @ticket.id
      el:        localEl.find('.edit')
      taskGet:   @taskGet
      formMeta:  @formMeta
      markForm:  @markForm
      taskKey:   @taskKey
    )

    if @permissionCheck('ticket.agent')
      @tagWidget = new App.WidgetTag(
        el:          localEl.filter('.tags')
        object_type: 'Ticket'
        object:      @ticket
        tags:        @tags
      )
      @linkWidget = new App.WidgetLink.Ticket(
        el:          localEl.filter('.links')
        object_type: 'Ticket'
        object:      @ticket
        links:       @links
      )

      for key, value of @not_verified_info
        if value
          @notVerifiedInfoWidget = new App.WidgetNotVerifiedInfo(
            el:          localEl.filter('.not_verified_info')
            object:      @not_verified_info
          )
          break


      if @permissionCheck('knowledge_base.*') and App.Config.get('kb_active')
        @linkKbAnswerWidget = new App.WidgetLinkKbAnswer(
          el:          localEl.filter('.link_kb_answers')
          object_type: 'Ticket'
          object:      @ticket
          links:       @links
        )

      @timeUnitWidget = new App.TicketZoomTimeUnit(
        el:        localEl.filter('.js-timeUnit')
        object_id: @ticket.id
      )
    @html localEl

  showTicketHistory: =>
    new App.TicketHistory(
      ticket_id: @ticket.id
      container: @el.closest('.content')
    )

  showTicketMerge: =>
    new App.TicketMerge(
      ticket:    @ticket
      taskKey:   @taskKey
      container: @el.closest('.content')
    )

  changeCustomer: =>
    new App.TicketCustomer(
      ticket_id: @ticket.id
      container: @el.closest('.content')
    )

App.Config.set('100-TicketEdit', SidebarTicket, 'TicketZoomSidebar')

# No usage of a ControllerObserver here because we want to use
# the data of the ticket zoom ajax request which is using the all=true parameter
# and contain the core workflow information as well. Without observer we also
# dont have double rendering because of the zoom (all=true) and observer (full=true) render callback
class Edit extends App.Controller
  constructor: (params) ->
    super
    @controllerBind('ui::ticket::load', (data) =>
      return if data.ticket_id.toString() isnt @ticket.id.toString()

      @ticket   = App.Ticket.find(@ticket.id)
      @formMeta = data.form_meta
      @render()
    )
    @render()

  render: =>
    defaults = @ticket.attributes()
    delete defaults.article # ignore article infos
    followUpPossible = App.Group.find(defaults.group_id).follow_up_possible
    ticketState = App.TicketState.find(defaults.state_id).name

    taskState = @taskGet('ticket')
    handlers = @Config.get('TicketZoomFormHandler')

    if !_.isEmpty(taskState)
      defaults = _.extend(defaults, taskState)
      # remove core workflow data because it should trigger a request to get data
      # for the new ticket + eventually changed task state
      @formMeta.core_workflow = undefined

    editable = @ticket.editable()
    if followUpPossible == 'new_ticket' && ticketState != 'closed' || followUpPossible != 'new_ticket' || @permissionCheck('admin') || @ticket.currentView() is 'agent'
      editable = !editable

    # reset updated_at for the sidbar because we render a new state
    # it is used to compare the ticket with the rendered data later
    # and needed to prevent race conditions
    @el.removeAttr('data-ticket-updated-at')

    # CSI Piemonte custom: get subitems to perform prefiltering, and added events
    subItems = App.ServiceCatalogSubItem.select (item) -> item.parent_service == defaults.service_catalog_item_id
    @formMeta.filter['service_catalog_sub_item_id'] = (item.id for item in subItems)

    @controllerFormSidebarTicket = new App.ControllerForm(
      elReplace:      @el
      model:          { className: 'Ticket', configure_attributes: @formMeta.configure_attributes || App.Ticket.configure_attributes }
      screen:         'edit'
      handlersConfig: handlers
      filter:         @formMeta.filter
      formMeta:       @formMeta
      params:         defaults
      isDisabled:     editable
      taskKey:        @taskKey
      core_workflow: {
        callbacks: [@markForm]
      }
      events:
        "change [name='service_catalog_item_id']": (e) => @filter_service_catalog_sub_items(e)
      #bookmarkable:  true
    )

    # set updated_at for the sidbar because we render a new state
    @el.attr('data-ticket-updated-at', defaults.updated_at)
    @markForm(true)

    return if @resetBind
    @resetBind = true
    @controllerBind('ui::ticket::taskReset', (data) =>
      return if data.ticket_id.toString() isnt @ticket.id.toString()
      @render()
    )

  # CSI custom: filter service_catalog_sub_items based on service_catalog_item
  filter_service_catalog_sub_items: (e) ->
    catalog_item = $(e.target)
    catalog_sub_item = catalog_item.parents('form').find("[name='service_catalog_sub_item_id']")

    selected_item = catalog_item.val()
    if !selected_item
      subItems = App.ServiceCatalogSubItem.all()
    else
      selected_item = Number(selected_item)
      subItems =  (item for item in  App.ServiceCatalogSubItem.all() when item.parent_service == selected_item)
    
    empty_option = new Option('-', '')
    catalog_sub_item.empty()
    catalog_sub_item.append(empty_option)

    subItems.forEach (option) ->
      o = new Option(option['name'], option['id'])
      $(o).html(option['name'])
      catalog_sub_item.append(o)
    
class SidebarTicket extends App.Controller
  constructor: ->
    super
    @controllerBind('config_update_local', (data) => @configUpdated(data))

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
    if @ticket.currentView() is 'agent'
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
      if args.mentions
        @mentionWidget.reload(args.mentions)
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
      ticket:    @ticket
      el:        localEl.find('.edit')
      taskGet:   @taskGet
      formMeta:  @formMeta
      markForm:  @markForm
      taskKey:   @taskKey
    )

    if @ticket.currentView() is 'agent'
      @mentionWidget = new App.WidgetMention(
        el:       localEl.filter('.js-subscriptions')
        object:   @ticket
        mentions: @mentions
      )
      @tagWidget = new App.WidgetTag(
        el:          localEl.filter('.js-tags')
        object_type: 'Ticket'
        object:      @ticket
        tags:        @tags
      )
      @linkWidget = new App.WidgetLink.Ticket(
        el:          localEl.filter('.js-links')
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
          el:          localEl.filter('.js-linkKbAnswers')
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

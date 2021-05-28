class ExternalActivity extends App.Controller
  sidebarItem: =>
    systems = []
    @ajax(
      id:    'ticketing_system_selector'
      type:  'GET'
      url:   "#{@apiPath}/external_ticketing_system"
      async: false
      success: (data, status, xhr) =>
        @systems = data
        cb = @loadSystem
        data.forEach (system) ->
          systems.push {
            title:    system.name
            name:     system.name
            callback: () -> cb(system)
          }
    )
    @item = {
      name: 'external_activity'
      badgeIcon: 'external'
      sidebarHead: 'Ticketing System'
      sidebarCallback: @showObjects
      sidebarActions: systems
    }
    @item

  loadSystem: (system) =>
    @system = system
    addButton = $(App.view('ticket_zoom/new_external_activity_button')(
      system: @system
    ))
    @html(addButton)
    @$('#external_activity_reload').on('click', () =>
      @reload()
      newActivityButton.hide()
    )
    @ajax(
      id:    'external_activities'
      type:  'GET'
      url:   "#{@apiPath}/external_activity/system/"+@system.id+"?ticket_id="+@ticket.id
      success: (data, status, xhr) =>
        cb = @displayExternalActivity
        if data.length > 0
          @$('.js-newExternalActivityLabel').hide()
          data.forEach (activity) ->
            cb(activity)

    )
    @fetchedOptions = []
    newActivityButton = @$('.js-newExternalActivityLabel')
    newActivityButton.on('click', () =>
       @createDispatchForm()
       newActivityButton.hide()
    )

  displayExternalActivity: (activity) =>
    externalActivityId = Math.floor(Math.random() * 10000) + 10000
    @$('.dispatch-box').append App.view('ticket_zoom/sidebar_external_activity_form')(
           system: @system
           externalActivityId : externalActivityId
           ticket : @ticket
           isAgent: @permissionCheck('ticket.agent')
           fields: Object.values(@system.model)
           dispatched: true
           needs_attention: activity.needs_attention
           values: activity.data
           activity: activity
         )
    @buildSelectFields(externalActivityId,activity)
    @buildCommentFields(externalActivityId,activity)
    @buildNeedsAttentionField(externalActivityId,activity)


  buildNeedsAttentionField: (externalActivityId,activity) =>
    needsAttentionButtonWrapper =
    needsAttentionButton = @$('#External_Activity_'+externalActivityId+'_needs_attention')
    needsAttentionButton.on('click', () =>
      @ajax(
        id:    'update_external_activity'
        type:  'PUT'
        url:   "#{@apiPath}/external_activity/"+activity["id"]
        data: JSON.stringify({needs_attention:false})
        success: (data, status, xhr) =>
      )
      needsAttentionButton.closest('.page-header-title').parent().hide()
    )


  createDispatchForm: () =>
    externalActivityId = Math.floor(Math.random() * 10000) + 10000
    @$('.dispatch-box').append App.view('ticket_zoom/sidebar_external_activity_form')(
      system: @system
      externalActivityId : externalActivityId
      ticket : @ticket
      isAgent: @permissionCheck('ticket.agent')
      fields: Object.values(@system.model)
    )

    @buildSelectFields(externalActivityId)

    @$('#External_Activity_'+externalActivityId+'_import-from-ticket').on('click', =>
      @importFieldsFromTicket(externalActivityId)
    )

    submitButton = @$('#External_Activity_'+externalActivityId+'_submit')
    submitButton.on('click', (e) =>
      e.preventDefault()
      submitButton.prop("disabled",true)
      @createExternalActivity(externalActivityId)
    )

  importFieldsFromTicket: (externalActivityId) =>
    instance = @
    @ajax(
      id:    'ticket'
      type:  'GET'
      url:   "#{@apiPath}/tickets/"+@ticket.id
      success: (data, status, xhr) =>
        $.each @system.model, (key, field) ->
          if field["core_field"]
            value = data[field["core_field"]]
            if field["select"] && field["select"]["service"]
              $.each instance.fetchedOptions[field["name"]], (index,option) ->
                if option["id"] == value
                  $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(option["name"])
                  return
            else
              $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(value)

    )
    @ajax(
      id:    'ticket_articles'
      type:  'GET'
      url:   "#{@apiPath}/ticket_articles/by_ticket/"+@ticket.id
      success: (data, status, xhr) =>
        $.each @system.model, (key, field) ->
          value = data[0][field["core_field"]]
          if field["core_field"] && value
            $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(value)
    )

  buildSelectFields: (externalActivityId,activity=null) =>
    instance = @
    $.each @system.model, (key, field) ->
      selectField = $('#External_Activity_'+externalActivityId+'_'+field["name"])
      if field["select"] != undefined
        for key, option of field["select"]["options"]
          instance.addOption(selectField, option)
        if field["select"]["service"] != undefined
          instance.fetchOptionValues(field,selectField,null,activity)
        else if activity != null && activity.data[field["name"]]
          instance.setOptionValue(selectField,activity.data[field["name"]])
        if activity==null && field["select"]["parent"] != undefined
          parent = $('#External_Activity_'+externalActivityId+'_'+field["select"]["parent"])
          parent.change ->
            instance.fetchOptionValues(field,selectField,@.value)

  buildCommentFields: (externalActivityId,activity=null) =>
    instance = @
    $.each @system.model, (key, field) ->
      commentField = instance.$('#External_Activity_'+externalActivityId+'_'+field["name"])
      if field["type"] == "comment" && activity!=null
        commentList = activity["data"][field["name"]]
        if !commentList
          commentList = {}
        selector = 'div[data-attribute-name="External_Activity_'+externalActivityId+'_'+field["name"]+'"]'
        jQuery.each commentList, (i, comment) ->
          instance.addComment(commentField, comment, selector)
        for key, comment of commentList
          instance.addComment(commentField, comment)
        commentButton = instance.$('#External_Activity_'+externalActivityId+'_'+field["name"]+'_comment_button')
        commentButton.on('click', (e) =>
          e.preventDefault()
          index = Object.keys(commentList).length+1
          commentList[""+index] = {
            "external":false,
            "text":commentField.val()
          }
          commentField.attr('disabled',true)
          commentButton.hide()
          activity["data"][field["name"]] = commentList
          instance.update_external_activity(activity)
        )


  update_external_activity: (activity) =>
    @ajax(
      id:    'update_external_activity'
      type:  'PUT'
      url:   "#{@apiPath}/external_activity/"+activity["id"]
      data: JSON.stringify({data:activity["data"]})
      success: (data, status, xhr) =>
    )


  addComment: (commentField,comment,selector) =>
    $(App.view('ticket_zoom/sidebar_external_activity_comment')(
      comment:comment
    )).insertBefore(selector)

  setOptionValue: (selectField,value) =>
     selectField.val(value)

  fetchOptionValues: (field,selectField,parentValue=null,activity=null) =>
    cb = @addOption
    url = "#{@apiPath}/"+field["select"]["service"]
    if parentValue!=null
      url+="?parent_id="+parentValue
    @.ajax(
      id:    'options for '+field["name"]
      type:  'GET'
      url: url
      success: (data, status, xhr) =>
        @fetchedOptions[field["name"]] = data
        selectField.empty().append('<option value>-</option>')
        data.forEach (option) =>
          cb(selectField,option)
        if activity != null && activity.data[field["name"]]
          @.setOptionValue(selectField,activity.data[field["name"]])
    )

  addOption: (selectField, option) =>
    o = new Option(option["name"], option["name"]);
    $(o).html(option["name"]);
    selectField.append(o);

  createExternalActivity: (externalActivityId) =>
    new_activity_fields = {}
    validated = true
    Object.values(@system.model).forEach (field) ->
      dom_field = @$('#External_Activity_'+externalActivityId+'_'+field.name)
      value = dom_field.val()
      if dom_field.prop('required') && value == ""
        validated = false
        return
      if field.type!='comment'
        new_activity_fields[field.name] = value
      else
        new_activity_fields[field.name] = {1:{
          "external": false,
          "text":value
        }}
    if !validated
      @$('#External_Activity_'+externalActivityId+'_hidden_submit').on 'click'
      return
    bidirectional_alignment = $('#External_Activity_'+externalActivityId+'_bidirectional_alignment:checkbox:checked').length > 0
    data = JSON.stringify(
      "ticketing_system_id":@system.id,
      "ticket_id":@ticket.id,
      "data": new_activity_fields,
      "bidirectional_alignment":bidirectional_alignment
    )
    @ajax(
      id:    'create_external_activity'
      type:  'POST'
      url:   "#{@apiPath}/external_activity"
      data: data
      success: (data, status, xhr) =>
        @loadSystem(@system)
    )

  showObjects: (el) =>
    @el = el
    @showObjectsContent()


  showObjectsContent: (objectIds) =>
    if @systems.length > 0
      @loadSystem(@systems[0])
    return

  showError: (message) =>
    @html App.i18n.translateInline(message)

  reload: =>
    @showObjectsContent()

  delete: (objectId) =>

  postParams: (args) =>

  updateTicket: (ticket_id, objectIds, callback) =>


App.Config.set('999-ExternalActivity', ExternalActivity, 'TicketZoomSidebar')

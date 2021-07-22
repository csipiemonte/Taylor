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
        if data.length==0
          @showNoSystemsMessage()
        instance = @
        data.forEach (system) ->
          systems.push {
            title:    system.name
            name:     system.name
            callback: () -> instance.loadSystem(system)
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

  showNoSystemsMessage: =>
    @html App.view('ticket_zoom/no_ticketing_systems_available')()

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
        # se uso actual_ticket_state_id = @ticket.state.id la variabile @ticket non e'aggiornata col nuovo valore se avviene update del ticket
        actual_ticket_state_id = $("form div[data-attribute-name=state_id] select option:selected").val()
        if actual_ticket_state_id == 4 or actual_ticket_state_id == "4"
          @$('.js-newExternalActivityLabel').hide()
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
    # if activity is closed or ticket is closed or user doesn't have rights for editing, prevent changes on external activity
    # se uso actual_ticket_state_id = @ticket.state.id la variabile @ticket non e'aggiornata col nuovo valore se avviene update del ticket
    actual_ticket_state_id = $("form div[data-attribute-name=state_id] select option:selected").val()
    closed = @isClosed(activity) || actual_ticket_state_id == "4" || actual_ticket_state_id == 4 || @system.permission != "rw"
    @$('.dispatch-box').append App.view('ticket_zoom/sidebar_external_activity_form')(
           system: @system
           externalActivityId : externalActivityId
           ticket : @ticket
           isAgent: @permissionCheck('ticket.agent')
           fields: Object.values(@system.model)
           dispatched: true
           closed : closed
           needs_attention: activity.needs_attention
           values: activity.data
           activity: @humanizeDate(activity)
         )
    instance = @
    callback = () -> instance.buildActivityElements(externalActivityId,activity)
    setTimeout callback,1500


  buildActivityElements: (externalActivityId,activity) =>
    @buildSelectFields(externalActivityId,activity)
    @buildCommentFields(externalActivityId,activity)
    @buildNeedsAttentionField(externalActivityId,activity)
    @buildUpdateButton(externalActivityId,activity)

  isClosed: (activity) =>
    closed = false
    $.each @system.model, (key,field) ->
      if field["closes_activity"]
        if field["closes_activity"].includes(activity.data[field["name"]])
          closed = true
          return
    return closed

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
    @buildCommentFields(externalActivityId)

    @$('#External_Activity_'+externalActivityId+'_import-from-ticket').on('click', =>
      @importFieldsFromTicket(externalActivityId)
    )
    submitButton = @$('#External_Activity_'+externalActivityId+'_submit')
    submitButton.on('click', (e) =>
      e.preventDefault()
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
            if value
              if field["select"] && field["select"]["service"]
                $.each instance.fetchedOptions[field["name"]], (index,option) ->
                  if option["id"] == value
                    $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(option["name"])
                    return
              else
                $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(value.replace(/<[^>]*>?/gm, ''))

    )
    @ajax(
      id:    'ticket_articles'
      type:  'GET'
      url:   "#{@apiPath}/ticket_articles/by_ticket/"+@ticket.id
      success: (data, status, xhr) =>
        $.each @system.model, (key, field) ->
          value = data[0][field["core_field"]]
          if field["core_field"] && value
            $('#External_Activity_'+externalActivityId+'_'+field["name"]).val(value.replace(/<[^>]*>?/gm, ''))
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
        if field["default"] != undefined
          instance.setOptionValue(selectField,field["default"])
        if activity != null && activity.data[field["name"]]
          instance.setOptionValue(selectField,activity.data[field["name"]])
        if field["select"]["parent"] != undefined
          parent = $('#External_Activity_'+externalActivityId+'_'+field["select"]["parent"])
          parent.change ->
            instance.fetchOptionValues(field,selectField,@.value)

  buildCommentFields: (externalActivityId,activity=null) =>
    instance = @
    $.each @system.model, (key, field) ->
      if field["type"] == "comment"
        if activity!=null
          commentField = instance.$('#External_Activity_'+externalActivityId+'_'+field["name"])
          commentList = activity["data"][field["name"]]
          if !commentList
            commentList = {}
          selector = 'div[data-attribute-name="External_Activity_'+externalActivityId+'_'+field["name"]+'"]'
          jQuery.each commentList, (i, comment) ->
            instance.addComment(commentField, comment, selector)
        if field["attachments"] && field["attachments"]["enabled"]
          instance.attachments = {}
          instance.buildAttachmentButton(externalActivityId,field,activity)

  buildAttachmentButton: (externalActivityId,field,activity=null) =>
    instance = @
    @attachments[field["name"]] = {}
    uploadAttachment = @$('#External_Activity_'+externalActivityId+'_'+field["name"]+'_fileUpload')
    comment_view = uploadAttachment.parents().eq(4);
    uploadAttachment.on('change', () =>
      files = uploadAttachment.prop("files")
      names = $.map(files, (val) -> return val.name )
      $.each(files, (i, file) =>
        attachment_view = $(App.view('generic/attachment_item')(
          filename:file.name
          size:file.size
        ))
        index = 0
        $.each(@attachments[field["name"]],(i) ->
          if i > index
            index = i
        )
        fileReader = new FileReader();
        fileReader.onload = (event) =>
          instance.attachments[field["name"]][parseInt(index)+1+i] = {
            "file":fileReader.result
            "name":file.name
          }
        fileReader.readAsText(file)
        comment_view.append(attachment_view)
        attachment_view.find('.attachment-delete.js-delete').on('click', () =>
          delete instance.attachments[field["name"]][parseInt(index)+1+i]
          attachment_view.remove()
        )
      )
    )

  buildUpdateButton: (externalActivityId,activity) =>
    instance = @
    @$('#External_Activity_'+externalActivityId+'_update_button').on('click', (e) =>
      e.preventDefault()
      [data,validated] = instance.readActivityValues externalActivityId, activity
      if !validated
        instance.$('#External_Activity_'+externalActivityId+'_hidden_submit').click()
        return
      activity["data"] = data
      @updateExternalActivity activity
    )


  updateExternalActivity: (activity) =>
    @ajax(
      id:    'update_external_activity'
      type:  'PUT'
      url:   "#{@apiPath}/external_activity/"+activity["id"]
      data: JSON.stringify({data:activity["data"]})
      success: (data, status, xhr) =>
        @loadSystem(@system)
    )


  addComment: (commentField,comment,selector) =>
    comment_view = $(App.view('ticket_zoom/sidebar_external_activity_comment')(
      comment: @humanizeDate(comment)
    ))
    if comment["attachments"]
      attachments = []
      $.each comment["attachments"], (key,attachment) ->
        file = new File([attachment["file"]], attachment["name"])
        attachment_view = $(App.view('generic/external_activity_attachment_item')(file))
        comment_view.append(attachment_view)
        attachment_view.on('click', () =>
          element = document.createElement('a');
          element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(attachment["file"]));
          element.setAttribute('download', attachment["name"]);
          element.style.display = 'none';
          document.body.appendChild(element);
          element.click();
          document.body.removeChild(element);
        )
    comment_view.insertBefore(selector)

  humanizeDate: (data) =>
    data["timestamp"] = App.i18n.translateTimestamp(data["created_at"])
    data["humanTime"] = App.PrettyDate.humanTime(data["created_at"], false)
    data

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
        if field["default"] != undefined
          @.setOptionValue(selectField,field["default"])
        if activity != null && activity.data[field["name"]]
          @.setOptionValue(selectField,activity.data[field["name"]])
    )

  addOption: (selectField, option) =>
    o = new Option(option["name"], option["name"])
    $(o).html(option["name"])
    selectField.append(o)
    if option["disabled"]
      $(o).addClass('text-muted').attr('disabled',true)

  createExternalActivity: (externalActivityId) =>
    [new_activity_fields,validated] = @readActivityValues externalActivityId
    if !validated
      @$('#External_Activity_'+externalActivityId+'_hidden_submit').click()
      return
    bidirectional_alignment = $('#External_Activity_'+externalActivityId+'_bidirectional_alignment:checkbox:checked').length > 0
    data = JSON.stringify(
      "ticketing_system_id":@system.id,
      "ticket_id":@ticket.id,
      "data": new_activity_fields,
      "bidirectional_alignment":bidirectional_alignment
    )
    @$('#External_Activity_'+externalActivityId+'_submit').prop("disabled",true)
    @ajax(
      id:    'create_external_activity'
      type:  'POST'
      url:   "#{@apiPath}/external_activity"
      data: data
      success: (data, status, xhr) =>
        @loadSystem(@system)
    )

  readActivityValues: (externalActivityId, activity=null) =>
    instance = @
    new_activity_fields = if activity then activity.data else {}
    validated = true
    $.each @system.model, (key,field) ->
      dom_field = instance.$('#External_Activity_'+externalActivityId+'_'+field.name)
      value = dom_field.val()
      if dom_field.prop('required') && value == ""
        validated = false
        return
      if field.type!='comment'
        new_activity_fields[field.name] = value
      else
        index = if activity && activity["data"][field.name] then new_activity_fields[field.name].length else 0
        new_activity_fields[field.name] = if activity && activity["data"][field.name] then new_activity_fields[field.name] else []
        has_attachments = Object.keys(instance.attachments[field["name"]]).length>0
        if value && value!="" || has_attachments
          new_activity_fields[field.name][index] = {
            "external": false,
            "text": if value then value else "",
            "created_at": new Date()
          }
          if has_attachments
            new_activity_fields[field.name][index]["attachments"] = if has_attachments then instance.attachments[field["name"]]

    return [new_activity_fields, validated]

  showObjects: (el) =>
    @el = el
    @showObjectsContent()


  showObjectsContent: (objectIds) =>
    if @systems.length > 0
      @loadSystem(@systems[0])
    else
      @showNoSystemsMessage()
    return

  showError: (message) =>
    @html App.i18n.translateInline(message)

  reload: =>
    @showObjectsContent()

  delete: (objectId) =>

  postParams: (args) =>

  updateTicket: (ticket_id, objectIds, callback) =>


App.Config.set('999-ExternalActivity', ExternalActivity, 'TicketZoomSidebar')

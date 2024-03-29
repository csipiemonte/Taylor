class ExternalActivity extends App.Controller
  
  sidebarItem: =>
    # feature toggle Sidebar external activity accessibile solo se feature attiva
    return if App.Feature.isDisabled('external_activity')

    # Sidebar external activity accessibile solo agli operatori del ticket
    return if !@permissionCheck('ticket.agent')
    systems = []
    instance = @
    @ajax(
      id:    'ticketing_system_selector'
      type:  'GET'
      url:   "#{@apiPath}/external_ticketing_system?ticket=" + @ticket.id
      async: false
      success: (data, status, xhr) =>
        @systems = data
        if data.length==0
          @showNoSystemsMessage()
        @activities_needing_attention = 0
        data.forEach (system) ->
          if system.activities_needing_attention
            instance.activities_needing_attention += system.activities_needing_attention
          systems.push {
            title:    system.name
            name:     system.name
            callback: -> instance.loadSystem(system)
          }
    )

    @item = {
      name: 'external_activity'
      badgeCallback: @badgeRender
      sidebarHead: 'Ticketing System'
      sidebarCallback: @showObjects
      sidebarActions: systems
    }
    @item

  badgeRender: (el) =>
    @badgeEl = el
    @badgeRenderLocal()

  badgeRenderLocal: (user) =>
    @badgeEl.html(App.view('generic/sidebar_tabs_item')(@metaBadge()))

  metaBadge: =>
    cssClass = ''
    {
      name: 'external_activities'
      icon: 'external'
      counterPossible: true
      counter: @activities_needing_attention
      cssClass: cssClass
    }

  showNoSystemsMessage: =>
    @html App.view('ticket_zoom/no_ticketing_systems_available')()

  loadSystem: (system, default_ext_act = null) =>
    console.log "[ExternalActivity] loadSystem #{@taskKey}"
    @system = system
    addButton = $(App.view('ticket_zoom/new_external_activity_button')(
      system: @system
    ))
    @html(addButton)
    #@$('#external_activity_reload').on('click', =>
    #  @reload()
    #  newActivityButton.hide()
    #)
    @ajax(
      id:    "external_activities-#{@taskKey}"
      type:  'GET'
      url:   "#{@apiPath}/external_activity/system/#{@system.id}?ticket_id=#{@ticket.id}"
      success: (data, status, xhr) =>
        console.log "[ExternalActivity] loadSystem callback (#{data.length} activities)"
        # se uso actual_ticket_state_id = @ticket.state.id la variabile @ticket non e'aggiornata col nuovo valore se avviene update del ticket
        actual_ticket_state_id = $('form div[data-attribute-name=state_id] select option:selected').val()
        if actual_ticket_state_id == 4 or actual_ticket_state_id == '4' # ticket_state_id = 4 corrisponde a ticket 'closed'
          @$('.js-newExternalActivityBtn').parent('div').hide()

        if data.length > 0
          ext_act_options = {}

          # get title core fields
          title_field = null
          for k, field of @system.model
            if field['core_field'] == 'title'
              title_field = field['name']
            if field['name'] in ['zammad_light_id', 'remedy_id']
              id_field = field['name']

          data.forEach (activity) =>
            # option for ext act selector
            option_name = if activity.json_data[id_field] then activity.json_data[id_field] else '-'
            #if title_field
            #  option_name += ' // ' + activity.json_data[title_field].slice(0, 15)

            ext_act_options[activity['id']] = option_name

            # build external activity
            @displayExternalActivity(activity)

          # build ext act selector
          selectField = App.UiElement.select.render(
            name: 'external_activity_select'
            options: ext_act_options
            value: data[0]['id']
          )

          @$('.js-external-activity-select')
            .html(selectField)
            .change((e) ->
              $('.external-activity-container').hide()
              selection = $(@).find('select[name=external_activity_select]').val()
              $(".external-activity-#{selection}").show()
            )

          # show ext act e selector
          default_ext_act = if default_ext_act then default_ext_act else data[0]['id']
          @$('.external-activity-select select').val(default_ext_act)
          @$('.external-activity-select').show()
          @$(".external-activity-#{default_ext_act}").show()
    
        # build new ext act form
        @createDispatchForm()
    )

    @fetchedOptions = []
    newActivityButton = @$('.js-newExternalActivityBtn')
    newActivityButton.on('click', =>
      @$('.external-activity-container').hide()
      @$('.external-activity-new').show()
    )

  displayExternalActivity: (activity) =>
    externalActivityId = Math.floor(Math.random() * 10000) + 10000
    # if activity is closed or ticket is closed or user doesn't have rights for editing, prevent changes on external activity
    # se uso actual_ticket_state_id = @ticket.state.id la variabile @ticket non e'aggiornata col nuovo valore se avviene update del ticket
    actual_ticket_state_id = $('form div[data-attribute-name=state_id] select option:selected').val()

    # ticket_state_id = 4 corrisponde a ticket 'closed'
    closed = @isClosed(activity) || actual_ticket_state_id == '4' || actual_ticket_state_id == 4 || @system.permission != 'rw'

    @$('.dispatch-box').append App.view('ticket_zoom/sidebar_external_activity_form')(
      system: @system
      externalActivityId : externalActivityId
      ticket : @ticket
      isAgent: @permissionCheck('ticket.agent')
      fields: Object.values(@system.model)
      dispatched: true
      closed : closed
      needs_attention: activity.needs_attention
      values: activity.json_data
      activity: @humanizeDate(activity)
    )
    instance = @
    @buildActivityElements(externalActivityId,activity)

  buildActivityElements: (externalActivityId,activity) =>
    @buildSelectFields(externalActivityId,activity)
    @buildCommentFields(externalActivityId,activity)
    @buildNeedsAttentionField(externalActivityId,activity)
    @buildUpdateButton(externalActivityId,activity)

  isClosed: (activity) =>
    closed = false
    $.each @system.model, (key,field) ->
      if field['closes_activity']
        if field['closes_activity'].includes(activity.json_data[field['name']])
          closed = true
          return
    return closed

  buildNeedsAttentionField: (externalActivityId, activity) =>
    apiPath = App.Config.get('api_path')

    needsAttentionButton = @$('#External_Activity_' + externalActivityId + '_needs_attention')
    needsAttentionButton.on('click', ->
      App.Ajax.request(
        id:    "update_external_activity_#{activity['id']}"
        type:  'PUT'
        url:   "#{apiPath}/external_activity/" + activity['id']
        async: false
        data: JSON.stringify({needs_attention: false})
        success: (data, status, xhr) ->
      )
      needsAttentionButton.closest('.page-header-title').parent().hide()
    )

  createDispatchForm: ->
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
      url:   "#{@apiPath}/tickets/" + @ticket.id
      success: (data, status, xhr) =>
        $.each @system.model, (key, field) ->
          if field['core_field']
            value = data[field['core_field']]
            if value
              if field['select'] && field['select']['service']
                $.each instance.fetchedOptions[field['name']], (index,option) ->
                  if option['id'] == value
                    $('#External_Activity_' + externalActivityId + '_' + field['name']).val(option['name'])
                    return
              else
                $('#External_Activity_' + externalActivityId + '_'+field['name']).val(value.replace(/<[^>]*>?/gm, ''))
    )
    @ajax(
      id:    'ticket_articles'
      type:  'GET'
      url:   "#{@apiPath}/ticket_articles/by_ticket/" + @ticket.id
      success: (data, status, xhr) =>
        $.each @system.model, (key, field) ->
          value = data[0][field['core_field']]
          if field['core_field'] && value
            $('#External_Activity_'+externalActivityId+'_'+field['name']).val(value.replace(/<[^>]*>?/gm, ''))
    )

  buildSelectFields: (externalActivityId,activity=null) =>
    instance = @
    $.each @system.model, (key, field) ->
      if field['select'] != undefined
        selectField = instance.$('#External_Activity_'+externalActivityId+'_'+field['name'])
        for key, option of field['select']['options']
          instance.addOption(selectField, option, field['select']['string_id'])
        if field['select']['service'] != undefined
          instance.fetchOptionValues(field, selectField, externalActivityId, null, activity)
        if field['default'] != undefined
          instance.setOptionValue(selectField,field['default'])
        if activity != null && activity.json_data[field['name']]
          instance.setOptionValue(selectField,activity.json_data[field['name']])
        if field['select']['parent'] != undefined
          parent = $('#External_Activity_'+externalActivityId+'_'+field['select']['parent'])
          parent.change ->
            if field['select']['string_id']
              parentValue = $(@).find(':selected').data('option-id')
            else
              parentValue = @.value

            instance.fetchOptionValues(field, selectField, externalActivityId, parentValue)

  buildCommentFields: (externalActivityId,activity=null) =>
    instance = @
    $.each @system.model, (key, field) ->
      if field['type'] == 'comment'
        if activity!=null
          commentField = instance.$('#External_Activity_'+externalActivityId+'_'+field['name'])
          commentList = activity['json_data'][field['name']]
          if !commentList
            commentList = {}
          selector = 'div[data-attribute-name="External_Activity_' + externalActivityId+'_' + field['name'] + '"]'
          jQuery.each commentList, (i, comment) ->
            instance.addComment(commentField, comment, selector)
        if field['attachments'] && field['attachments']['enabled']
          instance.attachments = {}
          instance.buildAttachmentButton(externalActivityId,field,activity)

  buildAttachmentButton: (externalActivityId,field,activity=null) =>
    instance = @
    @attachments[field['name']] = {}
    uploadAttachment = @$('#External_Activity_' + externalActivityId + '_' + field['name'] + '_fileUpload')
    comment_view = uploadAttachment.parents().eq(4)

    uploadAttachment.on('change', =>
      files = uploadAttachment.prop('files')
      names = $.map(files, (val) -> return val.name )
      $.each(files, (i, file) =>
        attachment_view = $(App.view('generic/attachment_item')(
          filename:file.name
          size:file.size
        ))
        index = 0
        $.each(@attachments[field['name']],(i) ->
          if i > index
            index = i
        )
        fileReader = new FileReader()
        fileReader.onload = (event) ->
          instance.attachments[field['name']][parseInt(index)+1+i] = {
            'file':fileReader.result
            'name':file.name
            'to_encode':true
          }
        fileReader.readAsDataURL(file)
        comment_view.append(attachment_view)
        attachment_view.find('.attachment-delete.js-delete').on('click', ->
          delete instance.attachments[field['name']][parseInt(index)+1+i]
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
        alert(__('Missing required fields'))
        #instance.$('#External_Activity_'+externalActivityId+'_hidden_submit').click()
        return
      activity['json_data'] = data
      @updateExternalActivity activity
    )

  updateExternalActivity: (activity) =>
    @ajax(
      id:    'update_external_activity'
      type:  'PUT'
      url:   "#{@apiPath}/external_activity/" + activity['id']
      data: JSON.stringify({json_data:activity['json_data']})
      success: (data, status, xhr) =>
        @loadSystem(@system, activity['id'])
    )

  addComment: (commentField, comment, selector) =>
    comment_view = $(App.view('ticket_zoom/sidebar_external_activity_comment')(
      comment: @humanizeDate(comment)
    ))
    if comment['attachments']
      attachments = []
      $.each comment['attachments'], (key,attachment) ->
        file = new File([attachment['file']], attachment['name'])
        attachment_view = $(App.view('generic/external_activity_attachment_item')(file))
        comment_view.append(attachment_view)
        attachment_view.on('click', ->
          element = document.createElement('a')

          if (attachment['file'].includes(';base64,') )
            # sono gia presenti metadati del file
            element.setAttribute('href', attachment['file'] )
          else
            #element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(attachment["file"]));
            # element.setAttribute('href', 'data:application/octet-stream;base64,' + attachment["file"]);
            element.setAttribute('href', 'data:text/plain;base64,' + attachment['file'])

          element.setAttribute('download', attachment['name'])
          element.style.display = 'none'
          document.body.appendChild(element)
          element.click()
          document.body.removeChild(element)
        )
    comment_view.insertBefore(selector)

  humanizeDate: (data) ->
    data['timestamp'] = App.i18n.translateTimestamp(data['created_at'])
    data['humanTime'] = App.PrettyDate.humanTime(data['created_at'], false)
    data

  setOptionValue: (selectField, value) ->
    selectField.val(value)

  fetchOptionValues: (field, selectField, activity_id, parentValue=null, activity=null) =>
    cb = @addOption
    url = "#{@apiPath}/" + field['select']['service']
    if parentValue!=null
      url += '?parent_id=' + parentValue
    @.ajax(
      id:    'options for ' + field['name'] + '_' + activity_id
      type:  'GET'
      url: url
      success: (data, status, xhr) =>
        @fetchedOptions[field['name']] = data
        selectField.empty().append('<option value>-</option>')
        data.forEach (option) ->
          cb(selectField,option,field['select']['string_id'])
        if field['default'] != undefined
          @.setOptionValue(selectField,field['default'])
        if activity != null && activity.json_data[field['name']]
          @.setOptionValue(selectField,activity.json_data[field['name']])
    )

  addOption: (selectField, option, string_id=undefined) ->
    if Number.isInteger(option['id']) && !string_id
      o = new Option(option['name'], option['id'])
    else
      o = new Option(option['name'], option['name'])

    id = if string_id then option['id'] else option['name']

    $(o).html(option['name'])
    $(o).attr('data-option-id', id)

    selectField.append(o)
    if option['disabled']
      $(o).addClass('text-muted').attr('disabled',true)

  createExternalActivity: (externalActivityId) =>
    [new_activity_fields,validated] = @readActivityValues externalActivityId
    if !validated
      alert(__('Missing required fields'))
      #@$('#External_Activity_'+externalActivityId+'_hidden_submit').click()
      return

    bidirectional_alignment = $('#External_Activity_'+externalActivityId+'_bidirectional_alignment:checkbox:checked').length > 0
    data = JSON.stringify(
      'ticketing_system_id':@system.id,
      'ticket_id':@ticket.id,
      'json_data': new_activity_fields,
      'bidirectional_alignment':bidirectional_alignment
    )
    @$('#External_Activity_' + externalActivityId + '_submit').prop('disabled', true)
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
    new_activity_fields = if activity then activity.json_data else {}
    validated = true
    $.each @system.model, (key,field) ->
      dom_field = instance.$('#External_Activity_'+externalActivityId+'_'+field.name)
      value = dom_field.val()
      if dom_field.prop('required') && value == ''
        validated = false
        return
      if field.type!='comment'
        new_activity_fields[field.name] = value
      else
        index = if activity && activity['json_data'][field.name] then new_activity_fields[field.name].length else 0
        new_activity_fields[field.name] = if activity && activity['json_data'][field.name] then new_activity_fields[field.name] else []
        has_attachments = Object.keys(instance.attachments[field['name']]).length>0
        if value && value != '' || has_attachments
          new_activity_fields[field.name][index] = {
            'external': false,
            'text': if value then value else '',
            'created_at': new Date()
          }
          if has_attachments
            new_activity_fields[field.name][index]['attachments'] = if has_attachments then instance.attachments[field['name']]

    return [new_activity_fields, validated]

  showObjects: (el) =>
    @el = el
    @showObjectsContent()
      

  showObjectsContent: (objectIds) =>
    # feature toggle Sidebar external activity accessibile solo se feature attiva
    return if App.Feature.isDisabled('external_activity')

    # Sidebar external activity accessibile solo agli operatori del ticket
    return if !@permissionCheck('ticket.agent')

    if @systems.length > 0
      @isRemedy = null
      for item in @systems
        if item.name == 'Remedy' # se nel codice è presente Remedy diventa default
          @isRemedy = item
      if @isRemedy
        @loadSystem(@isRemedy)
      else
        @loadSystem(@systems[0])
    else
      @showNoSystemsMessage()
    return

  showError: (message) =>
    @html App.i18n.translateInline(message)

  reload: =>
    @showObjectsContent()

  delete: (objectId) ->

  postParams: (args) ->

  updateTicket: (ticket_id, objectIds, callback) ->

App.Config.set('999-ExternalActivity', ExternalActivity, 'TicketZoomSidebar')

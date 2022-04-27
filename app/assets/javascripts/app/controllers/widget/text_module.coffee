class App.WidgetTextModule extends App.Controller
  searchCondition: {}
  constructor: ->
    super

    if !@data
      @data = {}

    # remember instances
    @bindElements = []
    if @selector
      @bindElements = @$(@selector).textmodule()
    else
      if @el.attr('contenteditable')
        @bindElements = @el.textmodule()
      else
        @bindElements = @$('[contenteditable]').textmodule()
    @update()

    @subscribeId = App.TextModule.subscribe(@update, initFetch: true)

    @controllerBind('TextModulePreconditionUpdate', (data) =>
      return if data.taskKey isnt @taskKey
      @searchCondition = data.params
      @update()
    )

  release: =>
    App.TextModule.unsubscribe(@subscribeId)

  reload: (data) =>
    return if !data
    @data = data
    @update()

  currentCollection: =>
    @all

  update: =>
    allRaw = App.TextModule.all()
    @all = []

    for item in allRaw

      if item.active isnt true
        continue

      if !_.isEmpty(item.group_ids) && @searchCondition.group_id && !_.includes(item.group_ids, parseInt(@searchCondition.group_id))
        continue

      # CSI custom: filtraggio addizionale per ogni modulo che non appartiene al gruppo dell'utente
      # merge groups permission from user.group_ids and user.roles.group_ids
      userGroups = [ @data?.user?.group_ids ]
      userGroups.push role.group_ids for role in @data?.user?.roles
      userGroups = Object.assign({}, userGroups...)

      userGroupIds = (id for id, value of userGroups)
      if !userGroupIds.some((el) -> item.group_ids.includes(parseInt(el)))
        continue

      attributes = item.attributes()
      attributes.content = App.Utils.replaceTags(attributes.content, @data)
      @all.push attributes

    # set new data
    if @bindElements[0]
      for element in @bindElements
        continue if !$(element).data().plugin_textmodule

        $(element).data().plugin_textmodule.searchCondition = @searchCondition
        $(element).data().plugin_textmodule.collection      = @all

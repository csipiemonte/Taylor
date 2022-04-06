class Internal
  @action: (actions, ticket, article, ui) ->
    return actions if ticket.currentView() is 'customer'

    if article.internal is true
      actions.push {
        name: __('set to public')
        type: 'public'
        icon: 'lock-open'
      }
    else
      actions.push {
        name: ('set to internal')
        type: 'internal'
        icon: 'lock'
      }

    actions

  @perform: (articleContainer, type, ticket, article, ui) ->
    return true if type isnt 'internal' && type isnt 'public'

    if type is 'public'
      if App.Config.get('ui_ticket_zoom_article_visibility_confirmation_dialog')
        new App.ControllerArticlePublicConfirm(
          callback: =>
            @change(articleContainer, article, ui)
          container: ui.el.closest('.content')
        )
      else
        @change(articleContainer, article, ui)
    else
      @change(articleContainer, article, ui)

    true

  @change: (articleContainer, article, ui) ->
    # storage update
    internal = true
    if article.internal == true
      internal = false
    ui.lastAttributes.internal = internal
    article.updateAttributes(internal: internal)

    # runtime update
    if internal
      articleContainer.addClass('is-internal')
      articleContainer.find('.is-internal-el').show()
    else
      articleContainer.removeClass('is-internal')
      articleContainer.find('.is-internal-el').hide()

    ui.render()


App.Config.set('100-Internal', Internal, 'TicketZoomArticleAction')

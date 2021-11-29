class App.UserCdp extends App.Controller
  constructor: (params) ->
    super

    # check authentication
    @authenticateCheckRedirect()

    # fetch new data if needed
    App.User.full(@user_id, @render)

  meta: =>
    meta =
      url: @url()
      id:  @user_id

    if App.User.exists(@user_id)
      user = App.User.find(@user_id)

      meta.head       = user.displayName()
      meta.title      = user.displayName()
      meta.iconClass  = user.icon()
    meta

  url: =>
    '#user_cdp/' + @user_id

  show: =>
    App.OnlineNotification.seen('User', @user_id)
    @navupdate(url: '#', type: 'menu')

  changed: ->
    false



  render: (user) =>

    if !@doNotLog
      @doNotLog = 1
      @recentView('User', @user_id)

    elLocal = $(App.view('user_cdp/index')(
      user: user
    ))

    new User(
      object_id: user.id
      el: elLocal.find('.js-profileName')
    )

    new CdpEvents(
      user_id: user.id
      el:   elLocal.find('.js-cdp-events')
    )


    @html elLocal

    new App.UpdateTastbar(
      genericObject: user
    )

  setPosition: (position) =>
    @$('.profile').scrollTop(position)

  currentPosition: =>
    @$('.profile').scrollTop()

class User extends App.ObserverController
  model: 'User'
  observe:
    firstname: true
    lastname: true
    organization_id: true
    image: true

  render: (user) =>
    if user.organization_id
      new Organization(
        object_id: user.organization_id
        el: @el.siblings('.js-organization')
      )

    @html App.view('user_cdp/name')(
      user: user
    )

class CdpEvents extends App.Controller
  events:
    'click .js-record': 'show'

  constructor: ->
    super
    @fetch()
    @records = []

  show: (e) =>
    e.preventDefault()

  fetch: =>
    @ajax(
      id:   "cdp_events_#{@user_id}"
      type: 'GET'
      url:  "#{@apiPath}/users/#{@user_id}/cdp_events"
      data:
        limit: @limit || 500
      processData: true
      success: (data) =>
        @scope_data = data['scope_data']
        @records = data['data']
        @global_satisfaction = data['global_nps_score'] 
        @charts_data = data['charts_data']
        @render()
    )

  render: =>
    datatable_records = data: @records
    
    @html App.view('user_cdp/cdp_events')(
      global_satisfaction: @global_satisfaction,
      scope_data: @scope_data
    )
    
    # console.error(datatable_records)
    
    @el.find('#cdp-events-table').DataTable
      'ajax': (data, callback, settings) ->
        callback datatable_records
        return
      "order": [[ 6, "desc" ]]
      'columns': [
        { 'data': (row, type, val, meta) ->
          if type == 'set'
            return
          else if type == 'display'
            icon_name = 'in-process'
            switch row.type
              when 'Feedback'
                if (row.properties.NPS_score < 4)
                  # icon_name = 'face-sad'
                  return '<p class="datatable-event-icon datatable-emoji-icon">☹️</p>'
                else if (row.properties.NPS_score < 8)
                  # icon_name = 'face-meh'
                  return '<p class="datatable-event-icon datatable-emoji-icon">😐</p>'
                else  
                  # icon_name = 'face-happy'
                  return '<p class="datatable-event-icon datatable-emoji-icon">🙂</p>'
              when 'Richiesta ad Assistenza'
                icon_name = 'in-process'
              when 'Pagamento'
                icon_name = 'rearange'
              when 'Prenotazione Appuntamento'
                icon_name = 'person'
              when 'Richiesta Documento'
                icon_name = 'clipboard'
              when 'Upload Documento'
                icon_name = 'cloud'
              when 'Download Documento'
                icon_name = 'download'
              when 'Stampa Documento'
                icon_name = 'printer'

            return '<svg class="datatable-event-icon" style=""><use xlink:href="assets/images/icons.svg#icon-'+icon_name+'"></use></svg>'
          else if type == 'filter'
            return row.type
          # 'sort', 'type' and undefined all just use the base value
          row.type
        }
        { 'data': 'type' }
        { 'data': 'scope' }
        { 'data': 'source.type' }
        { 'data': 'source.properties.name' }
        { 'data': 'properties.description' }
        { 'data': (row, type, val, meta) ->
          if type == 'set'
            return
          else if type == 'display' ||  type == 'filter'
            return moment(row.created_at).format('DD/MM/YYYY HH:mm')
          # 'sort', 'type' and undefined all just use the base value
          row.created_at
        }
      ]

    options = 
      series: @charts_data['scope_usage']['data']
      chart:
        width: 320
        type: 'pie'
      legend:
        show: true
        position: 'bottom'
      title:
        text: 'Interesse per Ambito'
        align: 'center'
        style:
          fontSize: '20px'
          fontWeight: 400
          fontFamily: 'Fira Sans'
      labels: @charts_data['scope_usage']['labels']
      responsive: [ {
        breakpoint: 480
        options:
          chart: width: 50
          legend: position: 'bottom'
      } ]
    chart = new ApexCharts(document.querySelector('#cdpChartScopes'), options)
    chart.render()


    # grafico satisfaction
    options = 
      series: [ { data: @charts_data['scope_nps']['data'] } ]
      chart:
        type: 'bar'
        height: 220
        toolbar: show: false
      title:
        text: 'Satisfaction per Ambito'
        align: 'center'
        style:
          fontSize: '20px'
          fontWeight: 400
          fontFamily: 'Fira Sans'
      plotOptions: bar:
        barHeight: '100%'
        distributed: true
        horizontal: true
        dataLabels: position: 'bottom'
      dataLabels:
        enabled: true
        textAnchor: 'start'
        style: colors: [ '#fff' ]
        formatter: (val, opt) ->
          opt.w.globals.labels[opt.dataPointIndex] + ':  ' + val
        offsetX: 0
        dropShadow: enabled: true
      legend: show: false
      stroke:
        width: 1
        colors: [ '#fff' ]
      xaxis: categories: @charts_data['scope_nps']['labels']
      yaxis: labels: show: false
      tooltip:
        theme: 'dark'
        x: show: false
        y: title: formatter: ->
          ''
    chart = new ApexCharts(document.querySelector('#cdpChartSatisfactionHisto'), options)
    chart.render()
    

class Router extends App.ControllerPermanent
  requiredPermission: 'ticket.agent'
  constructor: (params) ->
    super

    # cleanup params
    clean_params =
      user_id:  params.user_id

    App.TaskManager.execute(
      key:        "User-#{@user_id}"
      controller: 'UserCdp'
      params:     clean_params
      show:       true
    )

App.Config.set('user_cdp/:user_id', Router, 'Routes')

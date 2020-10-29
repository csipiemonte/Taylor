class Transaction::Remedy

=begin

  backend = Transaction::Slack.new(
    object: 'Ticket',
    type: 'update',
    object_id: 123,
    interface_handle: 'application_server', # application_server|websocket|scheduler
    changes: {
      'attribute1' => [before, now],
      'attribute2' => [before, now],
    },
    created_at: Time.zone.now,
    user_id: 123,
  )
  backend.perform

=end

  def initialize(item, params = {})
    @item = item
    @params = params
  end

  def perform
    # return if we run import mode
    return if Setting.get('import_mode')

    return if @item[:object] != 'Ticket'

    zammad_ticket = Ticket.find_by(id: @item[:object_id])
    return if !zammad_ticket
    ticket_text = ""
    if @item[:article_id]
      article = Ticket::Article.find(@item[:article_id])
      ticket_text = article.body
    end

    Rails.logger.info("[REMEDY INTEGRATION LOG] type is ="+@item[:type])
    if @item[:type] == "create"
      remedy_id = ""
      Rails.logger.info("[REMEDY INTEGRATION LOG] title is ="+zammad_ticket.title)
      if !zammad_ticket.title["REMEDY_CREATED"]
          Rails.logger.info("[REMEDY INTEGRATION LOG] creating Remedy ticket")
          ticket = {
            "riepilogo": 'XXXXXXXXXXXXXXX',
            "dettaglio": ticket_text,
            "impatto": "Vasto/Diffuso",
            "urgenza": "Critica",
            "tipologia": "Ripristino di servizio utente",
            "richiedente": {
              "personId": "PPL000000018476"
             },
            "categorizzazione": {
              "categoriaOperativa": {
                "livello1": "1L - Gestione PdL",
                "livello2": "Fornitura/Configurazione",
                "livello3": "PDL"
                }
            }
          }
          remedy_ticket = RemedyApiService.create_ticket(ticket)
          Rails.logger.info("[REMEDY INTEGRATION LOG] Remedy ticket created, id: #{remedy_ticket['ticketId']}")
          remedy_id = remedy_ticket['ticketId']
      else
        remedy_id = zammad_ticket.title[15..@item[:title].length-1]
      end
      zammad_ticket.remedy_id = remedy_id
      Rails.logger.info("[REMEDY INTEGRATION LOG] Saving Remedy ticket_id on Zammad DB")
      zammad_ticket.save!
      Rails.logger.info("[REMEDY INTEGRATION LOG] saved")
    end
  end

end

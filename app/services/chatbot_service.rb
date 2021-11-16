class ChatbotService

  def self.bind_supervisors(chat_session)
    supervisors = []
    Chat::Agent.where('active = ? OR updated_at > ?', true, Time.zone.now - 8.hours).each do |item|
      user = User.lookup(id: item.updated_by_id)
      next if !user
      next if !(user.role?('Supervisor') || user.role?('Admin'))

      supervisors << user
    end
    client_list = Sessions.sessions
    supervisors.each do |supervisor|
      client_list.each do |client_id|
        session = Sessions.get(client_id)
        next if !session
        next if !session[:user]
        next if !session[:user]['id']
        next if session[:user]['id'].to_i != supervisor.id.to_i
        next if chat_session.preferences[:participants].include? client_id

        chat_session.preferences[:participants] = chat_session.add_recipient(client_id)
      end
    end
    chat_session.save
  end
end

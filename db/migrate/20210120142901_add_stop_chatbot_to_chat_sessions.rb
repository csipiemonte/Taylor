class AddStopChatbotToChatSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_sessions, :stop_chatbot, :boolean
  end
end

class AddFlagRaisedToChatSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_sessions, :flag_raised, :boolean
  end
end

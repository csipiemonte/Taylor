class AddWhisperingToChatMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :chat_messages, :whispering, :boolean
  end
end

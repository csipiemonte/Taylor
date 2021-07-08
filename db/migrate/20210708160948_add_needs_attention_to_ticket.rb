class AddNeedsAttentionToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :needs_attention, :boolean, default: false, nil: false
  end
end

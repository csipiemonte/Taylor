class AddNeedsAttentionToExternalActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :external_activities, :needs_attention, :boolean, :default =>false
  end
end

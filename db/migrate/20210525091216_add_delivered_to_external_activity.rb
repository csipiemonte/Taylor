class AddDeliveredToExternalActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :external_activities, :delivered, :boolean, :default =>false
  end
end

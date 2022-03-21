class AddExternalActivityJson < ActiveRecord::Migration[6.0]
  def change
    #add_column :external_activities, :json_data, :jsonb, null: false, default: {}
    add_column :external_activities, :json_data, :jsonb
    add_index  :external_activities, :json_data, using: :gin
  end
end

class AddCreatedUpdatedByIdToExternalActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :external_activities, :created_by_id, :integer, null: false
    add_column :external_activities, :updated_by_id, :integer, null: false

    add_foreign_key :external_activities, :users, column: :created_by_id
    add_foreign_key :external_activities, :users, column: :updated_by_id
  end
end

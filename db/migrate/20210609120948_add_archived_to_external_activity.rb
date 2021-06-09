class AddArchivedToExternalActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :external_activities, :archived, :boolean, default: false
  end
end

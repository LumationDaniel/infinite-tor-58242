class AddDescriptionToCashActivities < ActiveRecord::Migration
  def change
    add_column :cash_activities, :description, :string, limit: 255
  end
end

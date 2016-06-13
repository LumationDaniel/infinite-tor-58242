class AddDeletedAtToCashActivities < ActiveRecord::Migration
  def change
    add_column :cash_activities, :deleted_at, :timestamp
  end
end

class AddGameIdToCashActivities < ActiveRecord::Migration
  def change
    add_column :cash_activities, :game_id, :integer
    add_index :cash_activities, :game_id
  end
end

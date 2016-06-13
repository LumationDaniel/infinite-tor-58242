class IndexCashActivitiesByCode < ActiveRecord::Migration
  def up
    add_index :cash_activities, :code
  end

  def down
    remove_index :cash_activities, :code
  end
end

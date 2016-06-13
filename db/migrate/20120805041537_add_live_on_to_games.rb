class AddLiveOnToGames < ActiveRecord::Migration
  def up
    add_column :games, :live_on, :timestamp
    execute 'UPDATE games SET live_on = created_at'
  end

  def down
    remove_column :games, :live_on
  end
end

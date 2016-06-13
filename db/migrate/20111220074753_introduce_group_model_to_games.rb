class IntroduceGroupModelToGames < ActiveRecord::Migration
  def up
    add_column :games, :group_id, :integer
    remove_column :games, :league_id
  end

  def down
    add_column :games, :league_id, :integer
    remove_column :games, :group_id
  end
end

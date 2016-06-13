class AddRankingsAndTvChannelToGames < ActiveRecord::Migration
  def change
    add_column :games, :home_team_rank, :integer
    add_column :games, :away_team_rank, :integer
    add_column :games, :tv_channel, :string
  end
end

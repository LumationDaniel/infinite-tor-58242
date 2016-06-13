class AddCashPrizeToGames < ActiveRecord::Migration
  def up
    add_column :games, :cash_prize, :integer
    execute <<-SQL
      UPDATE games SET cash_prize = 500
    SQL
  end

  def down
    remove_column :games, :cash_prize
  end
end

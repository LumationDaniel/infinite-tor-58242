class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.references :league
      t.references :home_team
      t.references :away_team
      t.timestamp :starts_at
      t.timestamps
    end
  end
end

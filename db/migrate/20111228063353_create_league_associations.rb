class CreateLeagueAssociations < ActiveRecord::Migration
  def change
    create_table :league_associations do |t|
      t.string :name
      t.timestamps
    end
  end
end

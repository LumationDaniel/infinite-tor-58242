class IntroduceLeagueAssocations < ActiveRecord::Migration
  def up
    add_column :teams, :league_association_id, :integer
    add_index :teams, :league_association_id

    add_column :leagues, :league_association_id, :integer
    remove_column :leagues, :name

    remove_column :teams, :league_id
  end

  def down
    add_column :teams, :league_id, :integer

    remove_column :leagues, :league_association_id, :integer
    add_column :leagues, :name, :string

    remove_index :teams, :league_association_id
    remove_column :teams, :league_association_id
  end
end

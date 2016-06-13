class CreateGameGroups < ActiveRecord::Migration
  def change
    create_table :game_groups do |t|
      t.references :league
      t.string :name
      t.integer :position
      t.timestamps
    end
    add_index :game_groups, :league_id
  end
end

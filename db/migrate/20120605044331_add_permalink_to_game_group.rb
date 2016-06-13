class AddPermalinkToGameGroup < ActiveRecord::Migration
  def self.up
    add_column :game_groups, :permalink, :string
    add_index :game_groups, :permalink
  end
  def self.down
    remove_column :game_groups, :permalink
  end
end
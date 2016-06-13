class AddPermalinkToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :permalink, :string
    add_index :sites, :permalink
  end
  def self.down
    remove_column :sites, :permalink
  end
end
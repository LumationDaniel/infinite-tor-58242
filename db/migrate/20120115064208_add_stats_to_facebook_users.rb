class AddStatsToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :cash_updated_at, :timestamp
    add_column :facebook_users, :local_rank, :integer, :default => 0
    add_column :facebook_users, :global_rank, :integer, :default => 0
    add_column :facebook_users, :wins, :integer, :default => 0
    add_column :facebook_users, :loses, :integer, :default => 0
  end
end

class AddLastFacebookSyncAtToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :last_facebook_sync_at, :timestamp
  end
end

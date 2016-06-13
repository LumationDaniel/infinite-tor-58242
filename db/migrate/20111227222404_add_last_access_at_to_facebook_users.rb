class AddLastAccessAtToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :last_access_at, :datetime
    execute 'UPDATE facebook_users SET last_access_at = created_at'
  end
end

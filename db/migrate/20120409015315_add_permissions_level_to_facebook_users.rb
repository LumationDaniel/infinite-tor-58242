class AddPermissionsLevelToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :permissions_level, :integer
    execute <<-SQL
      UPDATE facebook_users SET permissions_level = 0 WHERE email IS NULL;
    SQL
    execute <<-SQL
      UPDATE facebook_users SET permissions_level = 1 WHERE email IS NOT NULL;
    SQL
  end
end

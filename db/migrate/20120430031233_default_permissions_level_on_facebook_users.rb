class DefaultPermissionsLevelOnFacebookUsers < ActiveRecord::Migration
  def up
    change_column_default :facebook_users, :permissions_level, 0
  end

  def down
  end
end

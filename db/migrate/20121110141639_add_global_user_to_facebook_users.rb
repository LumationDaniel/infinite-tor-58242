class AddGlobalUserToFacebookUsers < ActiveRecord::Migration
  def up
    add_column :facebook_users, :global_user, :boolean, default: false
    execute <<-SQL
      UPDATE facebook_users SET global_user = #{quoted_true}
    SQL
  end

  def down
    remove_column :facebook_users, :global_user
  end
end

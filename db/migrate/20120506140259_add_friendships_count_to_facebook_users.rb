class AddFriendshipsCountToFacebookUsers < ActiveRecord::Migration
  def up 
    add_column :facebook_users, :friendships_count, :integer, default: 0

    execute <<-SQL
      UPDATE facebook_users
      SET friendships_count = friends.total_friendships
      FROM (
        SELECT
          user_id,
          COUNT(user_id) AS total_friendships
        FROM friendships
        GROUP BY user_id
      ) AS friends
      WHERE friends.user_id = facebook_users.id;
    SQL
  end

  def down
    remove_column :facebook_users, :friendships_count
  end
end

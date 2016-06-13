class AddLikesAppPageToFacebookUsers < ActiveRecord::Migration
  def up
    remove_column :facebook_users, :like_bonus_awarded
    add_column :facebook_users, :likes_app_page, :boolean, default: false
  end

  def down
    remove_column :facebook_users, :likes_app_page
    add_column :facebook_users, :like_bonus_awarded, :boolean, default: false
  end
end

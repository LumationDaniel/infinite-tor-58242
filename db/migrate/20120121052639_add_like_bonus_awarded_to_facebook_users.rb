class AddLikeBonusAwardedToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :like_bonus_awarded, :boolean, default: false
  end
end

class AddDailyBonusLastAwardedOnToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :daily_bonus_last_awarded_on, :timestamp
  end
end

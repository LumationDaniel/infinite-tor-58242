class AddScoreToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :score, :integer, :default => 0
    add_index :facebook_users, :score
  end
end

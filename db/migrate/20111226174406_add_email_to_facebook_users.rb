class AddEmailToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :email, :string, limit: 120
  end
end

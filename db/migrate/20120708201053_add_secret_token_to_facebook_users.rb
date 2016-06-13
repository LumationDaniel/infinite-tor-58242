class AddSecretTokenToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :secret_token, :string
  end
end

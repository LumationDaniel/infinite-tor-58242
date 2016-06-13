class CreateFacebookUsers < ActiveRecord::Migration
  def change
    create_table :facebook_users do |t|
      t.string :facebook_id
      t.string :oauth_token
      t.timestamp :oauth_token_expires_at

      t.string :first_name
      t.string :last_name
      t.string :link
      t.string :username

      t.timestamps
    end
    add_index :facebook_users, :facebook_id
  end
end

class CreateFriendships < ActiveRecord::Migration
  def change
    create_table :friendships do |t|
      t.references :user
      t.references :other_user
      t.timestamps
    end
    add_index :friendships, :user_id
  end
end

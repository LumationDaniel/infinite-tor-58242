class RenameUsersScoreToCash < ActiveRecord::Migration
  def up
    remove_index :facebook_users, :score
    rename_column :facebook_users, :score, :cash
    add_index :facebook_users, :cash
  end

  def down
    remove_index :facebook_users, :cash
    rename_column :facebook_users, :cash, :score
    add_index :facebook_users, :score
  end
end

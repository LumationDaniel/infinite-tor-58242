class RemoveCashUpdatedAtFromFacebookUsers < ActiveRecord::Migration
  def up
    remove_column :facebook_users, :cash_updated_at
  end

  def down
    add_column :facebook_users, :cash_updated_at, :datetime
  end
end

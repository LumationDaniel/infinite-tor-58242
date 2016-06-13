class AddSiteIdToAdminUsers < ActiveRecord::Migration
  def change
    add_column :admin_users, :site_id, :integer
  end
end

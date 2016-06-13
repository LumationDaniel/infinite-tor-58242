class AddFacebookSettingsToSites < ActiveRecord::Migration
  def change
    add_column :sites, :facebook_app_id, :string
    add_column :sites, :facebook_app_secret, :string
    add_column :sites, :facebook_app_url, :string
    add_column :sites, :facebook_app_access_token, :string, limit: 255
  end
end

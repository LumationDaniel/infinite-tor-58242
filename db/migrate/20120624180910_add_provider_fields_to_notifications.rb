class AddProviderFieldsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :provider_type, :string
    add_column :notifications, :method_name, :string
    add_index :notifications, [:provider_type, :method_name]
  end
end

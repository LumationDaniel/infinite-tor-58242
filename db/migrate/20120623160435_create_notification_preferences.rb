class CreateNotificationPreferences < ActiveRecord::Migration
  def change
    create_table :notification_preferences do |t|
      t.references :user
      t.references :notification
      t.timestamp :unsubscribed_on
      t.timestamps
    end
    add_index :notification_preferences, :user_id
    add_index :notification_preferences, :notification_id
  end
end

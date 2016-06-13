class CreateUserAnnouncements < ActiveRecord::Migration
  def change
    create_table :user_announcements do |t|
      t.references :user
      t.references :announcement
      t.timestamp  :read_on
      t.timestamps
    end
    add_index :user_announcements, :user_id
    add_index :user_announcements, :read_on
  end
end

class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.string :message, limit: 200
      t.integer :priority, default: 0
      t.timestamp :retired_at
      t.timestamps
    end
  end
end

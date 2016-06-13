class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :name
      t.references :parent
      t.timestamps
    end
  end
end

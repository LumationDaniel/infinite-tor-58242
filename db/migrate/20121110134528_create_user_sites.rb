class CreateUserSites < ActiveRecord::Migration
  def change
    create_table :user_sites do |t|
      t.references :user
      t.references :site
      t.timestamps
    end
    add_index :user_sites, :site_id
    add_index :user_sites, :user_id
  end
end

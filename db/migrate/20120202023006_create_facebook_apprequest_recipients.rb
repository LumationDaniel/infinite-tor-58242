class CreateFacebookApprequestRecipients < ActiveRecord::Migration
  def change
    create_table :facebook_apprequest_recipients do |t|
      t.references :user
      t.string :name
      t.string :facebook_id
      t.references :facebook_apprequest
      t.timestamp  :deleted_apprequest_at
      t.timestamps
    end
    add_index :facebook_apprequest_recipients, :user_id
    add_index :facebook_apprequest_recipients, :facebook_id
  end
end

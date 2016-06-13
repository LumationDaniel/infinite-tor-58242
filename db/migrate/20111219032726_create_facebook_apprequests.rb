class CreateFacebookApprequests < ActiveRecord::Migration
  def change
    create_table :facebook_apprequests do |t|
      t.references :target, :polymorphic => true
      t.references :user
      t.string :request_id
      t.string :request_type
      t.timestamps
    end
    add_index :facebook_apprequests, :request_id
  end
end

class ChangeFacebookIdTypeOnFacebookApprequestRecipients < ActiveRecord::Migration
  def up
    remove_index "facebook_apprequest_recipients", ["facebook_id"]
    change_column "facebook_apprequest_recipients", "facebook_id", :string
    add_index "facebook_apprequest_recipients", ["facebook_id"]
  end

  def down
    remove_index "facebook_apprequest_recipients", ["facebook_id"]
    change_column "facebook_apprequest_recipients", "facebook_id", :integer
    add_index "facebook_apprequest_recipients", ["facebook_id"]
  end
end

class AddQuestionCountersToFacebookUsers < ActiveRecord::Migration
  def change
    add_column :facebook_users, :correct_answers, :integer, default: 0
    add_column :facebook_users, :incorrect_answers, :integer, default: 0
  end
end

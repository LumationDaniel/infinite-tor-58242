class AddQuestionIdToCashActivities < ActiveRecord::Migration
  def change
    add_column :cash_activities, :question_id, :integer
    add_index :cash_activities, :question_id
  end
end

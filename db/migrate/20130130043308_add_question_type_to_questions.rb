class AddQuestionTypeToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :question_type, :string, default: 'predictive'
  end
end

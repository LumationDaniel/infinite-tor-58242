class CreateUserAnswers < ActiveRecord::Migration
  def change
    create_table :user_answers do |t|
      t.references :user
      t.references :question
      t.references :answer
      t.timestamps
    end
    add_index :user_answers, :user_id
    add_index :user_answers, :question_id
  end
end

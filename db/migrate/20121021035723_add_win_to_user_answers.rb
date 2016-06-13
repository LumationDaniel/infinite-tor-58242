class AddWinToUserAnswers < ActiveRecord::Migration
  def change
    add_column :user_answers, :win, :boolean
  end
end

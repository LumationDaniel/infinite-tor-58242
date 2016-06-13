class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :question, null: false
      t.string :text, null: false
      t.boolean :right_answer, null: false, default: false
      t.integer :position, null: false
      t.timestamps
    end
    add_index :answers, :question_id
  end
end

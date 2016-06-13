class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.references :site
      t.references :creator, null: false
      t.string :text, null: false
      t.timestamp :completed_on
      t.timestamp :live_on
      t.timestamp :locked_on
      t.timestamps
    end
    add_index :questions, :site_id
    add_index :questions, :live_on
    add_index :questions, :completed_on
  end
end

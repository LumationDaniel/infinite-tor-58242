class CreateChallenges < ActiveRecord::Migration
  def change
    create_table :challenges do |t|
      t.references :opponent
      t.references :challenger_entry
      t.references :opponent_entry
      t.integer :wager_amount
      t.string :state
      t.string :opponent_facebook_id
      t.string :opponent_name
      t.timestamps
    end
    add_index :challenges, :challenger_entry_id
    add_index :challenges, :opponent_facebook_id
  end
end

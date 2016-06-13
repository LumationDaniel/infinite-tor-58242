class CreatePickemEntries < ActiveRecord::Migration
  def change
    create_table :pickem_entries do |t|
      t.references :user
      t.references :game
      t.references :winner
      t.timestamps
    end
    add_index :pickem_entries, :user_id
    add_index :pickem_entries, :game_id
  end
end

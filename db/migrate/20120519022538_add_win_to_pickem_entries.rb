class AddWinToPickemEntries < ActiveRecord::Migration
  def up 
    add_column :pickem_entries, :win, :boolean
  end

  def down
    remove_column :pickem_entries, :win
  end
end

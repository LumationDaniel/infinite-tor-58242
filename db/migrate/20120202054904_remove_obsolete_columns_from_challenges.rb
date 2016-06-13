class RemoveObsoleteColumnsFromChallenges < ActiveRecord::Migration
  def up
    remove_column :challenges, 'opponent_facebook_id'
    remove_column :challenges, 'opponent_name'
  end

  def down
    add_column :challenges, 'opponent_facebook_id', :string
    add_column :challenges, 'opponent_name', :string
  end
end

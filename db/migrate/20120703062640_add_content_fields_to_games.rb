class AddContentFieldsToGames < ActiveRecord::Migration
  def change
    add_column :games, :name, :string
    add_column :games, :description, :string
  end
end

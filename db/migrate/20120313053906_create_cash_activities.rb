class CreateCashActivities < ActiveRecord::Migration
  def change
    create_table :cash_activities do |t|
      t.references :user
      t.references :source, polymorphic: true
      t.integer :amount
      t.string :code
      t.timestamp :created_at
    end

    add_index :cash_activities, :user_id
    add_index :cash_activities, :created_at
  end
end

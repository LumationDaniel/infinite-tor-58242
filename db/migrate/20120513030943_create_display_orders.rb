class CreateDisplayOrders < ActiveRecord::Migration
  def change
    create_table :display_orders do |t|
      t.string :scope
      t.references :target, polymorphic: true
      t.integer :priority
      t.timestamps
    end
  end
end

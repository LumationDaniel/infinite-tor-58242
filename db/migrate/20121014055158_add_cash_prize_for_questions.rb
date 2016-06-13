class AddCashPrizeForQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :cash_prize, :integer
  end
end

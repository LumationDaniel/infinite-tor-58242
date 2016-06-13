class SetStartingBalanceCashActivity < ActiveRecord::Migration
  def up
    execute("INSERT INTO cash_activities(user_id, amount, code, created_at) SELECT id, cash, 'starting_balance', CURRENT_TIMESTAMP FROM facebook_users;")
  end

  def down
  end
end

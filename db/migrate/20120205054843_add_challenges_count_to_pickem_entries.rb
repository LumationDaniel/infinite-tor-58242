class AddChallengesCountToPickemEntries < ActiveRecord::Migration
  def up
    add_column :pickem_entries, :challenges_count, :integer, default: 0

    execute <<-SQL
UPDATE pickem_entries
SET challenges_count = COALESCE(challenges_count, 0) + sq.cnt
FROM (
  SELECT COUNT(c.id) AS cnt, c.challenger_entry_id
  FROM challenges c
  WHERE state IN ('open', 'accepted')
  GROUP BY challenger_entry_id
  ) AS sq
WHERE pickem_entries.id = sq.challenger_entry_id;
SQL

    execute <<-SQL
UPDATE pickem_entries
SET challenges_count = COALESCE(challenges_count, 0) + sq.cnt
FROM (
  SELECT COUNT(c.id) AS cnt, c.opponent_entry_id
  FROM challenges c
  WHERE opponent_entry_id IS NOT NULL
  AND state IN ('accepted')
  GROUP BY opponent_entry_id
  ) AS sq
WHERE pickem_entries.id = sq.opponent_entry_id;
SQL
  end

  def down
    remove_column :pickem_entries, :challenges_count
  end
end

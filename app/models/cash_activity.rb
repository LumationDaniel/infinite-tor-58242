class CashActivity < ActiveRecord::Base
  EARNINGS_CODES = %w(win loss challenge_win challenge_lose correct incorrect)

  belongs_to :user, class_name: 'FacebookUser'
  belongs_to :source, polymorphic: true
  belongs_to :game
  belongs_to :question

  default_scope where("#{quoted_table_name}.deleted_at IS NULL")
  scope :earnings, where(code: EARNINGS_CODES)

  # This is a hack so that we can filter by game groups in cash activities
  scope :for_group_eq, lambda { |g| joins(:game).where(["#{Game.quoted_table_name}.group_id = ?", g.to_param]) }
  search_methods :for_group_eq

  scope :codes_contains, lambda { |c| where(["#{quoted_table_name}.code in (?)", c.split(',').map(&:strip)]) }
  search_methods :codes_contains

  def cancel!
    FacebookUser.update_counters(user_id, cash: -amount)
    touch(:deleted_at)
  end
end

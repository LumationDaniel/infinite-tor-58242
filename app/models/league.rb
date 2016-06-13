class League < ActiveRecord::Base
  belongs_to :league_association
  has_many :game_groups
  has_many :games, :through => :game_groups

  attr_accessible :league_association_id, :sport, as: :admin

  scope :with_upcoming_games,
      select("distinct #{League.quoted_table_name}.*").joins(:games).
      where("#{Game.quoted_table_name}.starts_at > CURRENT_TIMESTAMP AND #{Game.quoted_table_name}.live_on <= CURRENT_TIMESTAMP")

  scope :with_recently_past_games,
      select("distinct #{League.quoted_table_name}.*").joins(:games).
      where("#{Game.quoted_table_name}.starts_at BETWEEN (CURRENT_TIMESTAMP - INTERVAL '7 days') AND (CURRENT_TIMESTAMP - INTERVAL '1 second')")

  def label
    "#{league_association.try(:name)} #{sport}"
  end
  alias :to_s :label
end

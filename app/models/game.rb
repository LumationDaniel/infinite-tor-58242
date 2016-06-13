require 'jobs/process_game_results'

class Game < ActiveRecord::Base
  audited

  belongs_to :group, class_name: 'GameGroup'
  belongs_to :home_team, class_name: 'Team'
  belongs_to :away_team, class_name: 'Team'
  has_many :pickem_entries, dependent: :destroy

  attr_accessible :group_id, :away_team_rank, :away_team_id, :home_team_rank,
      :home_team_id, :starts_at, :tv_channel, :away_score, :home_score,
      :completed, :name, :description, :live_on, :cash_prize, as: :admin

  validates_presence_of :home_team_id, :away_team_id, :group_id, :starts_at

  scope :pickable     , lambda { where('starts_at > ?', Time.zone.now) }
  scope :ids          , lambda { |ids| where("#{self.quoted_table_name}.id in (?)", ids) }
  scope :upcoming     , where("starts_at > CURRENT_TIMESTAMP")
  scope :recently_past, where("starts_at BETWEEN (CURRENT_TIMESTAMP - INTERVAL '7 days') AND (CURRENT_TIMESTAMP - INTERVAL '1 second')")
  scope :completed    , where(completed: true)
  scope :pending      , where(completed: false)
  scope :live         , lambda { where('live_on <= ?', Time.zone.now) }

  # retrieves games including the winner_id if the user made a pick
  scope :user    , lambda { |user|
    join = <<-JOIN_CLAUSE_SQL
LEFT OUTER JOIN #{PickemEntry.quoted_table_name}
  ON #{PickemEntry.quoted_table_name}.game_id = #{Game.quoted_table_name}.id
  AND #{PickemEntry.quoted_table_name}.user_id = #{user.id}
JOIN_CLAUSE_SQL
    joins(join).select("#{Game.quoted_table_name}.*, #{PickemEntry.quoted_table_name}.winner_id, #{PickemEntry.quoted_table_name}.challenges_count")
  }

  before_create :set_live_on
  after_save :process_game_results
  after_initialize do |q|
    q.cash_prize ||= Settings[:cash_per_win].to_i
  end

  delegate :league, to: :group

  def title
    "#{(away_team.try(:name) || 'Unknown')} at #{(home_team.try(:name) || 'Unknown')}"
  end

  def started?
    starts_at.past? || completed?
  end

  def completed?
    read_attribute(:completed)
  end

  def tie?
    completed? && away_score == home_score
  end

  def cash_penalty_for_loss
    -(cash_prize * 0.5)
  end

  def recently_completed?
    !!@recently_completed
  end

  def recently_uncompleted?
    !!@recently_uncompleted
  end

  def completed=(completed)
    completed = false if completed == '0'
    if self.completed?
      if !completed
        @recently_uncompleted = true
        write_attribute(:completed, completed)
      end
    else
      if completed
        @recently_completed = true
        write_attribute(:completed, completed)
      end
    end
  end

  def winner?
    !!winner
  end

  def winner
    return nil unless completed?
    if away_score > home_score
      away_team
    elsif away_score < home_score
      home_team
    end
  end

  protected
    def process_game_results
      if recently_completed? && winner?
        Delayed::Job.enqueue ::Jobs::ProcessGameResults.new(id, true)
      elsif recently_uncompleted?
        Delayed::Job.enqueue ::Jobs::ProcessGameResults.new(id, false)
      end
      true # false would abort save
    end

    def set_live_on
      self.live_on = Time.now if live_on.nil?
    end
end

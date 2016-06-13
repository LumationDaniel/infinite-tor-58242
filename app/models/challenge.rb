class Challenge < ActiveRecord::Base
  belongs_to :opponent, class_name: 'FacebookUser'

  belongs_to :challenger_entry, class_name: 'PickemEntry'
  belongs_to :opponent_entry  , class_name: 'PickemEntry'

  has_many :apprequests,
    class_name: 'FacebookApprequest',
    foreign_key: 'target_id',
    conditions: { request_type: 'challenge', target_type: 'Challenge' },
    dependent: :destroy

  after_create :increment_challenger_entry_counter

  scope :awaiting_response, where(state: 'open')
  scope :active, where('state in (?)', %w(open accepted))
  scope :accepted, where(state: 'accepted')
  scope :facebook_id, lambda { |fb_id| joins(apprequests: :request_recipients).where("#{FacebookApprequestRecipient.quoted_table_name}.facebook_id = ?", fb_id) }

  validates_presence_of :challenger_entry_id, :wager_amount, :state
  validates_numericality_of :wager_amount, greater_than: 0

  attr_accessible :wager_amount

  delegate :game, to: :challenger_entry

  state_machine :state, initial: :open do
    before_transition :on => :accept  , :do => :set_opponent_pick
    before_transition :on => :finalize, :do => :settle_wager
    before_transition :completed => :accepted, :do => :revert_wager
    after_transition :open => any - :open, :do => :delete_apprequests
    after_transition :open => :accepted, :do => :increment_opponent_entry_counter
    after_transition :open => :declined, :do => :decrement_challenger_entry_counter

    event :accept do
      transition :open => :accepted, unless: :opponent_has_same_email?
    end

    event :decline do
      transition :open => :declined
    end

    event :finalize do
      transition :accepted => :completed
      transition :open => :expired
    end

    event :unfinalize do
      transition :completed => :accepted
      transition :expired => :open
    end
  end

  def title
    [game.away_team, game.home_team].map do |t|
      "#{t.try(:name) || 'Unknown'}#{' (w)' if game.winner == t}"
    end.join(' at ')
  end

  def apprequest
    apprequests.first
  end

  def challenger
    challenger_entry.user
  end

  def challengers_pick
    challenger_entry.winner
  end

  def opponents_pick
    game.home_team == challenger_entry.winner ? game.away_team : game.home_team
  end

  def challenger_name
    challenger.full_name
  end

  def opponent_name
    opponent.try(:full_name) || apprequest.request_recipient.name
  end

  def opponent_facebook_id
    opponent.try(:facebook_id) || apprequest.request_recipient.facebook_id
  end

  def winner
    challenger_entry.win? ? challenger : opponent
  end

  def loser
    challenger_entry.win? ? opponent : challenger
  end

  def send_challenge_notice
    ChallengeMailer.deliver_if_subscribed(opponent, :notice, self) if opponent
  end

  def opponent_has_same_email?
    opponent.email == challenger.email
  end

  protected

    def settle_wager
      if accepted? && !game.tie?
        winner.update_cash!(wager_amount, 'challenge_win', self)
        loser.update_cash!(-wager_amount, 'challenge_lose', self)
      end
    end

    def revert_wager
      CashActivity.where(
        code: %w(challenge_win challenge_lose),
        source_id: id,
        game_id: challenger_entry.game_id
      ).each(&:cancel!)
    end

    def set_opponent_pick
      return false if opponent.accessible_cash < wager_amount

      entry = opponent.pickem_entries.for_game(game).first
      self.opponent_entry = if entry && entry.winner_id == challenger_entry.loser.id
        entry
      else
        opponent.make_pick!(game, challenger_entry.loser)
      end
    end

    def delete_apprequests
      apprequests.each(&:delete_all_facebook_requests!)
    end

    def increment_challenger_entry_counter
      PickemEntry.update_counters(challenger_entry_id, challenges_count: 1)
    end

    def decrement_challenger_entry_counter
      PickemEntry.update_counters(challenger_entry_id, challenges_count: -1)
    end

    def increment_opponent_entry_counter
      PickemEntry.update_counters(opponent_entry_id, challenges_count: 1)
    end
end

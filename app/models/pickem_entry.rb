class PickemEntry < ActiveRecord::Base
  belongs_to :user, :class_name => 'FacebookUser'
  belongs_to :game
  belongs_to :winner, :class_name => 'Team'

  has_many :outgoing_challenges, class_name: 'Challenge', foreign_key: 'challenger_entry_id', dependent: :destroy
  has_many :incoming_challenges, class_name: 'Challenge', foreign_key: 'opponent_entry_id'  , dependent: :destroy

  scope :user     , lambda { |user| where(user_id: user.to_param.to_i) }
  scope :games    , lambda { |games| where('game_id in (?)', games.collect { |g| g.to_param.to_i }) }
  scope :for_game , lambda { |game| where(game_id: game.to_param.to_i ) }
  scope :wins     , where(win: true)

  validate :game_hasnt_started
  validate :no_active_challenges

  delegate :title, to: :game

  def loser
    game.away_team_id == winner_id ? game.home_team : game.away_team
  end

  def can_change_pick?
    !started? && challenges_count <= 0
  end

  protected

    def game_hasnt_started
      if game.started? && (new_record? || winner_id_changed?)
        errors.add(:base, 'Cannot make or change pick after game has started')
      end
    end

    def no_active_challenges
      if !new_record? && challenges_count > 0 && winner_id_changed?
        errors.add(:base, 'Cannot change pick that is participating in a challenge')
      end
    end
end

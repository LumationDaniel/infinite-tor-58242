module Fb::ChallengesHelper
  def challenger_name(challenge)
    me?(challenge.challenger) ? 'You' : @challenge.challenger_name
  end

  def challenge_opponent_name(challenge)
    me?(challenge.opponent) ? 'You' : @challenge.opponent_name
  end
end

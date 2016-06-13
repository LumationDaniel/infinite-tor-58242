module Fb::GamesHelper
  def team_entry_classes(game, team_type)
    classes = [ 'team', team_type ]

    team = game.send("#{team_type}_team")
    classes << 'disabled' if disable_pick?(game)

    if game.completed? && !game.tie? && team.id == game.winner_id.to_i
      classes << if win?(game)
        'correct'
      else
        'incorrect'
      end
    else
      classes << 'check' if team.id == game.winner_id.to_i
    end

    classes.join(' ')
  end

  def win?(game)
    game.winner_id.to_i == game.winner.id
  end

  def disable_pick?(game)
    game.started? || game.challenges_count.to_i > 0
  end

  def has_picks?(games)
    !!games.flatten.detect { |g| g.winner_id != nil }
  end
end

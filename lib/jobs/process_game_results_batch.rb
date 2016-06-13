require 'jobs/update_facebook_score'

module Jobs
  class ProcessGameResultsBatch < Struct.new(:game_id, :entry_ids, :completed)
    def perform
      game = Game.find(game_id)

      if completed
        perform_completed(game)
      else
        perform_uncompleted(game)
      end
    end

    def perform_uncompleted(game)
      winners = []
      losers  = []

      PickemEntry.where('id in (?)', entry_ids).each do |entry|
        if entry.win
          winners << entry.user_id
          CashActivity.where(code: 'win', source_id: entry.id).first.cancel!
        else
          losers << entry.user_id
          CashActivity.where(code: 'loss', source_id: entry.id).first.cancel!
        end

        entry.win = nil
        entry.save
        entry.outgoing_challenges.where(state: %w(completed expired)).each(&:unfinalize!)
      end

      FacebookUser.update_counters(winners, :wins  => -1)
      FacebookUser.update_counters(losers , :loses => -1)

      update_scores(winners)
      update_scores(losers)
    end

    def perform_completed(game)
      winners = []
      losers  = []

      cash_per_win  = game.cash_prize
      cash_per_loss = game.cash_penalty_for_loss

      PickemEntry.where('id in (?)', entry_ids).each do |entry|
        if entry.winner_id == game.winner.try(:id)
          winners << entry.user_id
          entry.win = true
          entry.save
          entry.user.update_cash!(cash_per_win, 'win', entry)

        elsif !game.tie?
          losers << entry.user_id
          entry.win = false
          entry.save
          entry.user.update_cash!(cash_per_loss, 'loss', entry)
        end
        entry.outgoing_challenges.active.each(&:finalize!)
      end

      FacebookUser.update_counters(winners, wins: 1)
      FacebookUser.update_counters(losers , loses: 1)

      update_scores(winners)
      update_scores(losers)
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end

    def update_scores(user_ids)
      user_ids.each { |id| Delayed::Job.enqueue(UpdateFacebookScore.new(id)) }
    end

  end
end

module Jobs
  class ProcessQuestionResultsBatch < Struct.new(:question_id, :user_answer_ids, :completed)
    def perform
      question = Question.find(question_id)

      if completed
        perform_completed(question)
      else
        perform_uncompleted(question)
      end
    end

    def perform_uncompleted(question)
      winners = []
      losers  = []

      CashActivity.where(source_id: user_answer_ids).each(&:cancel!)
      UserAnswer.where('id in (?)', user_answer_ids).each do |user_answer|
        (user_answer.win? ? winners : losers) << user_answer.user_id
        user_answer.win = nil
        user_answer.save
      end

      FacebookUser.update_counters(winners, correct_answers: -1)
      FacebookUser.update_counters(losers , incorrect_answers: -1)
    end

    def perform_completed(question)
      winners = []
      losers  = []

      cash_per_win  = question.cash_prize
      cash_per_loss = question.cash_penalty_for_loss

      UserAnswer.where('id in (?)', user_answer_ids).each do |user_answer|
        if user_answer.correct?
          winners << user_answer.user_id
          user_answer.win = true
          user_answer.save
          user_answer.user.update_cash!(cash_per_win, 'correct', user_answer)

        else
          losers << user_answer.user_id
          user_answer.win = false
          user_answer.save
          user_answer.user.update_cash!(cash_per_loss, 'incorrect', user_answer)
        end
      end

      FacebookUser.update_counters(winners, correct_answers: 1)
      FacebookUser.update_counters(losers , incorrect_answers: 1)
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end
  end
end

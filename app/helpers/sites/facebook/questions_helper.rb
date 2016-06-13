module Sites::Facebook::QuestionsHelper

  def answer_item(answer)
    classes = ['answer', cycle('even', 'odd')].tap do |c|
      c << 'disabled' unless answer.question.can_change_answer?
      chosen_answer = (answer.id == answer.question.answer_id.to_i)
      if answer.question.completed? && chosen_answer
        c << (answer.right_answer? ? 'correct' : 'incorrect')
        c << 'check'
      elsif chosen_answer
        c << 'check'
      end
    end

    link_to '#', class: classes.join(' '),
                 title: (answer.question.can_change_answer? ? "Click to choose this answer" : 'Cannot change answer'),
                 'data-answer-id' => answer.id do
      yield
    end
  end

end

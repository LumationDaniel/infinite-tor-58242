class Answer < ActiveRecord::Base
  belongs_to :question, inverse_of: :answers
  acts_as_list :scope => :question
  attr_accessible :text, :right_answer, as: :admin

  validate :can_only_have_one_right_answer

  protected
    def can_only_have_one_right_answer
      if question.answers.many?(&:right_answer?)
        errors.add(:right_answer, "Question cannot have more than one right answer")
      end
    end

end

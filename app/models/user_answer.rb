class UserAnswer < ActiveRecord::Base
  belongs_to :user, class_name: 'FacebookUser'
  belongs_to :question
  belongs_to :answer

  before_validation :set_question

  # attr_accessible :title, :body
  scope :for_question, lambda { |q| where(question_id: q.id) }

  delegate :text, to: :answer

  def correct?
    answer.right_answer?
  end

  def cash_result
    if correct?
      question.cash_prize
    else
      question.cash_penalty_for_loss
    end
  end

  protected
    def set_question
      self.question = answer.question if question.nil?
    end
end

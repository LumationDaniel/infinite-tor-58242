require 'jobs/process_question_results'

class Question < ActiveRecord::Base
  belongs_to :site
  belongs_to :creator, class_name: 'AdminUser'
  has_many :answers, order: :position, inverse_of: :question, dependent: :destroy
  has_many :user_answers, inverse_of: :question, dependent: :destroy

  attr_accessible :text, :live_on, :locked_on, :answers_attributes,
                  :cash_prize, :completed, :site_id, :question_type, as: :admin

  accepts_nested_attributes_for :answers, :reject_if => proc { |h| h[:text].blank? }

  validate :cannot_be_completed_without_right_answer

  scope :upcoming         , where("#{quoted_table_name}.locked_on > CURRENT_TIMESTAMP")
  scope :live             , lambda { where('live_on IS NULL OR live_on <= ?', Time.zone.now) }
  scope :recently_past    , where("completed_on BETWEEN (CURRENT_TIMESTAMP - INTERVAL '7 days') AND (CURRENT_TIMESTAMP - INTERVAL '1 second')")
  scope :pending          , where("#{quoted_table_name}.completed_on IS NULL")
  scope :completed        , where("#{quoted_table_name}.completed_on IS NOT NULL")
  scope :completed_on_date, lambda { |d| completed.where(locked_on: [d.beginning_of_day..d.end_of_day]) }
  scope :locked           , where("#{quoted_table_name}.locked_on < CURRENT_TIMESTAMP")
  scope :trivia           , where(question_type: 'trivia')
  scope :predictive       , where(question_type: 'predictive')

  # retrieves questions including the answer_id if the user made a pick
  scope :user, lambda { |user|
    joins(<<SQL).select("#{Question.quoted_table_name}.*, #{UserAnswer.quoted_table_name}.answer_id")
  LEFT OUTER JOIN #{UserAnswer.quoted_table_name}
               ON #{UserAnswer.quoted_table_name}.question_id = #{Question.quoted_table_name}.id
              AND #{UserAnswer.quoted_table_name}.user_id = #{user.id}
SQL
  }

  validate :must_have_right_answer, if: :trivia_question?

  after_save :process_game_results
  after_initialize do |q|
    q.cash_prize ||= 500
  end

  def trivia_question?
    question_type == 'trivia'
  end

  def predictive_question?
    question_type == 'predictive'
  end

  def right_answer
    answers.detect(&:right_answer?)
  end

  def locked?
    locked_on.past?
  end

  def can_change_answer?
    !completed? && !locked?
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

  def completed?
    completed_on?
  end
  alias :completed :completed?

  def completed=(completed)
    completed = false if completed == '0'
    if self.completed?
      if !completed
        @recently_uncompleted = true
        self.completed_on = nil
      end
    else
      if completed
        @recently_completed = true
        self.completed_on = Time.now
      end
    end
  end

  protected
    def process_game_results
      if recently_completed?
        Delayed::Job.enqueue ::Jobs::ProcessQuestionResults.new(id, true)
      elsif recently_uncompleted?
        Delayed::Job.enqueue ::Jobs::ProcessQuestionResults.new(id, false)
      end
      true # false would abort save
    end

    def cannot_be_completed_without_right_answer
      if completed? and !answers.any?(&:right_answer?)
        errors.add(:completed, "cannot be set without select a right answer")
      end
    end

    def must_have_right_answer
      errors.add(:text, "Trivia questions must have a right answer") unless right_answer
    end
end

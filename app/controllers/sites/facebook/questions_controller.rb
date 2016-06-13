class Sites::Facebook::QuestionsController < Sites::Facebook::BaseController

  layout 'site'

  def upcoming
    @questions = site.questions.
                  live.
                  upcoming.
                  user(current_user).
                  where("#{UserAnswer.quoted_table_name}.answer_id IS NULL").
                  order('locked_on ASC')
  end

  def picks
    @questions = site.questions.
                  live.
                  upcoming.
                  pending.
                  user(current_user).
                  where("#{UserAnswer.quoted_table_name}.answer_id IS NOT NULL").
                  order('locked_on ASC')
  end

  def completed
    @questions = site.questions.
                  recently_past.
                  user(current_user).
                  where("#{UserAnswer.quoted_table_name}.answer_id IS NOT NULL").
                  order('locked_on DESC')
  end

end

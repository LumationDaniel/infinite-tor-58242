class Sites::Facebook::AnswersController < Sites::Facebook::BaseController

  def update
    respond_to do |f|
      f.text do
        if current_user
          current_user.answer_question!(Answer.includes(:question).find(params[:answer_id]))
          render status: 200, nothing: true
        else
          render status: 401, nothing: true
        end
      end
    end
  end

end

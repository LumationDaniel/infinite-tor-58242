module Jobs
  class UpdateUserRankings < Struct.new(:user_id)
    def perform
      FacebookUser.find(user_id).update_rankings!
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end

    def failure(job, exception)
      Airbrake.notify(exception)
    end
  end
end
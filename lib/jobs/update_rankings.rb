module Jobs
  class UpdateRankings
    def perform
      total_users = FacebookUser.count
      FacebookUser.find_each(batch_size: 200) do |user|
        user.global_rank = total_users        - FacebookUser.where('cash <= ? AND id <> ?', user.cash, user.id).count
        user.local_rank  = user.friends.count - user.friends.where('cash <= ?', user.cash).count + 1
        user.save(validate: false)
      end
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end

    def failure(job, exception)
      Airbrake.notify(exception)
    end
  end
end
module Jobs
  class UpdateFacebookScore < Struct.new(:user_id)
    def perform
      user = FacebookUser.find(user_id)
      graph_api = Koala::Facebook::API.new(::FB[:access_token])
      graph_api.graph_call("/#{user.facebook_id}/scores", {score: user.cash}, 'post')
    end
  end
end


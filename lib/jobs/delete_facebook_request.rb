require 'koala'

module Jobs
  class DeleteFacebookRequest < Struct.new(:facebook_id, :request_ids)
    def perform
      graph_api = Koala::Facebook::API.new(FB[:access_token])
      request_ids.each do |request_id|
        graph_api.delete_object([request_id, facebook_id].join('_'))
      end
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end
  end
end
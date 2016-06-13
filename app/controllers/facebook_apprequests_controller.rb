require 'jobs/delete_facebook_request'

class FacebookApprequestsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    @apprequests = FacebookApprequest.recipient(current_user).to_a

    invalid_apprequests_ids = @apprequests.select(&:invalid?).collect(&:id)

    # put the first valid and specified request at the top
    if request_ids = params[:request_ids]
      request_ids.split(',').each do |id|
        if req = @apprequests.detect { |r| r.request_id == id }
          if @apprequests.first != req
            @apprequests.unshift(@apprequests.delete(req))
          end
          break
        else
          invalid_apprequests_ids << id
        end
      end
    end

    Delayed::Job.enqueue ::Jobs::DeleteFacebookRequest.new(current_user.facebook_id, invalid_apprequests_ids)
  end

  def challenge
    req = FacebookApprequest.new
    req.request_id = params[:request_id]
    req.request_type = 'challenge'
    req.target_id = params[:game]
    req.target_type = 'Game'
    req.user = current_user
    req.save

    respond_to do |format|
      format.text do
        render :text => 'OK', :status => 201
      end
    end
  end
end

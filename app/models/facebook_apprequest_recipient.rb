class FacebookApprequestRecipient < ActiveRecord::Base
  belongs_to :user, class_name: 'FacebookUser'
  belongs_to :request, class_name: 'FacebookApprequest', foreign_key: 'facebook_apprequest_id'

  before_save :check_user_updated
  after_save :update_user_on_target

  protected
    def check_user_updated
      @found_user = user_id_changed?
      true
    end

    def update_user_on_target
      if @found_user && request.request_type.challenge?
        request.target.opponent_id = user_id
        request.target.save(validate: false)
      end
    end
end

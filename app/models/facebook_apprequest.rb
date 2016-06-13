require 'jobs/delete_facebook_request'

class FacebookApprequest < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :user, class_name: 'FacebookUser'

  has_many :request_recipients, class_name: 'FacebookApprequestRecipient', dependent: :destroy
  has_many :recipients, class_name: 'FacebookUser', through: :request_recipients, source: :user

  scope :recipient, lambda { |user| joins(:request_recipients).where("#{FacebookApprequestRecipient.quoted_table_name}.user_id = ? AND #{FacebookApprequestRecipient.quoted_table_name}.deleted_apprequest_at IS NULL", user.id) }

  validates_presence_of :request_id

  def request_recipient
    request_recipients.first
  end

  def request_type
    @request_type ||= ActiveSupport::StringInquirer.new(read_attribute(:request_type))
  end

  def invalid?
    # checking for target type b/c older challenge requests had a Game target
    request_type.challenge? && !target.kind_of?(Challenge)
  end

  def delete_all_facebook_requests!
    request_recipients.each do |recipient|
      Delayed::Job.enqueue ::Jobs::DeleteFacebookRequest.new(recipient.facebook_id, [request_id])
      recipient.touch(:deleted_apprequest_at)
    end
  end
end

class NotificationPreference < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification

  scope :for_notification, lambda { |n| where(notification_id: n.to_param) }

  def subscribed?
    unsubscribed_on.nil?
  end
end

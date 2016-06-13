class UserAnnouncement < ActiveRecord::Base
  belongs_to :user, class_name: 'FacebookUser'
  belongs_to :announcement

  scope :read   , where('read_on IS NOT NULL')
  scope :unread , where('read_on IS NULL')
end

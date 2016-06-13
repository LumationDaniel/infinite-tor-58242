class Announcement < ActiveRecord::Base
  belongs_to :site

  attr_accessible :message, :priority, :retired_at, as: :admin

  scope :active     , where('retired_at IS NULL OR retired_at > CURRENT_TIMESTAMP')
  scope :prioritized, order('priority DESC, created_at')
  scope :retired    , where('retired_at IS NOT NULL AND retired_at < CURRENT_TIMESTAMP')

  scope :unread_by  , lambda { |u|
    exists_sql = u.user_announcements.read.select(:id).where('announcement_id = announcements.id').to_sql
    where("NOT EXISTS(#{exists_sql})")
  }
end

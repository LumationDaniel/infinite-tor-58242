class DisplayOrder < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  acts_as_list column: 'priority', scope: [:scope]

  attr_accessible :scope, :target_id, :target_type, :priority, as: :admin

  validates :scope, :target_id, :target_type, presence: true

  default_scope :order => 'priority'
  scope :leaderboard, conditions: { scope: 'leaderboard' }

  delegate :label, to: :target
end

class Notification < ActiveRecord::Base
  has_many :notifications, foreign_key: 'parent_id', class_name: 'Notification'
  belongs_to :parent, foreign_key: 'parent_id', class_name: 'Notification'

  scope :provider_and_method, lambda { |p, m| where(provider_type: p, method_name: m) }

  attr_accessible :subject, as: :admin

  def description
    read_attribute(:description) || name
  end
end

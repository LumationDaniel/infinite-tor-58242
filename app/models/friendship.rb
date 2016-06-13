class Friendship < ActiveRecord::Base
  belongs_to :user, class_name: 'FacebookUser', counter_cache: true
  belongs_to :other_user, class_name: 'FacebookUser'
end

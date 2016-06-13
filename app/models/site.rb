class Site < ActiveRecord::Base
  has_many :admins, class_name: 'AdminUser'
  has_many :questions
  has_many :announcements
  has_many :users, class_name: 'FacebookUser', through: :user_sites
  has_many :user_sites

  has_permalink :name

  attr_accessible :name, :permalink, :facebook_app_secret, :facebook_app_id,
                  :facebook_app_url, :facebook_app_access_token, as: :admin
end

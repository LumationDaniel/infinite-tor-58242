source 'http://rubygems.org'

#gem 'rails', '3.2.11'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.2.3'
  gem 'bourbon'
end

gem 'jquery-rails'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
gem 'acts_as_list'
gem 'has_permalink'
gem 'gibbon'
gem 'mandrill', git: 'git://github.com/cyu/mandrill.git'
gem 'audited-activerecord'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'
gem 'thin'

# Deploy with Capistrano
# gem 'capistrano'

group :test do
  # Pretty printed test output
  gem 'turn', '0.8.2', :require => false
end

group :development do
  gem 'sqlite3', require: false
  gem 'heroku', require: false
  gem 'taps', require: false

gem 'rails_12factor', require: false
  # Need to keep this commented out or it will break heroku
  # gem 'ruby-debug19', :require => 'ruby-debug'
end

gem 'pg'

# Facebook API
gem 'koala', :git => 'https://github.com/arsduo/koala.git'

# Global Settings
gem 'setler'

# Admin
gem 'activeadmin'
gem 'activeadmin-cancan', git: 'git://github.com/cyu/activeadmin-cancan.git', branch: 'v0.1.4-cyu'
gem "meta_search" , '>= 1.1.0.pre'
# moved this outside of :asset group otherwise it fails on heroku
gem 'sass-rails'  , '~> 3.2.4'

gem 'delayed_job_active_record'
gem 'state_machine'

# Needed for using cookies in iframe in IE
gem 'rack-p3p'

# Needed for 3rd party cookies in Safari
gem 'useragent'

# Monitoring
#gem 'airbrake'
gem 'newrelic_rpm'


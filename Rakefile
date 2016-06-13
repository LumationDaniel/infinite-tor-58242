#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Pickem::Application.load_tasks

namespace :assets do
  task :check_environment do
    raise ENV['RAILS_ENV']
  end
  #task :precompile => :check_environment
end

namespace :rankings do
  desc "Update user rankings"
  task :update => :environment do
    require 'jobs/update_rankings'
    Delayed::Job.enqueue ::Jobs::UpdateRankings.new
  end
end
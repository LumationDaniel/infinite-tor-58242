task :daily_update => :environment do
  require 'jobs/daily_update'
  Jobs::DailyUpdate.perform
end

task :daily_site_update => :environment do
  require 'jobs/daily_site_update'
  Jobs::DailySiteUpdate.perform
end

task :re_engagement => :environment do
  if Time.now.in_time_zone('America/New_York').tuesday?
    require 'jobs/re_engagement'
    Jobs::ReEngagement.perform
  end
end

task :complete_trivia_questions => :environment do
  require 'jobs/complete_trivia_questions'
  Jobs::CompleteTriviaQuestions.perform
end

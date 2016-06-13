namespace :facebook do
  task :app_access_token => :environment do
    # https://developers.facebook.com/docs/opengraph/using-app-tokens/
    auth = Koala::Facebook::OAuth.new(FB[:app_id], FB[:app_secret]) 
    puts auth.get_app_access_token
  end
end

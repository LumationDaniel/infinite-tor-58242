module Jobs
  class SyncFacebookProfile < Struct.new(:user_id)
    def perform
      if fb_user.valid_access_token?
        update_profile
        update_friends
        fb_user.check_likes_app_page
        fb_user.update_rankings!
      else
        puts "OAuth token expired for Facebook user #{user_id}, skipping sync job"
      end
    end

    def error(job, exception)
      Airbrake.notify(exception)
    end

  protected
    def update_profile
      profile = graph_api.get_object("me")
      fb_user.first_name = profile['first_name']
      fb_user.last_name  = profile['last_name']
      fb_user.link       = profile['link']
      fb_user.username   = profile['username']
      fb_user.email      = profile['email']
    end

    def update_friends
      friends_result = graph_api.get_connections("me", "friends")
      all_friends = []
      until friends_result.empty?
        user_friends = FacebookUser.where('facebook_id IN (?)', friends_result.collect { |f| f['id'] })
        all_friends.concat(user_friends)
        friends_result = friends_result.next_page
      end

      all_friends.each do |friend|
        unless fb_user.friends_with?(friend)
          fb_user.friends << friend
        end
        unless friend.friends_with?(fb_user)
          friend.friends << fb_user
        end
      end

      fb_user.friendships.each do |f|
        if !all_friends.include?(f.other_user)
          f.destroy
        end
      end
    end

    def fb_user
      @fb_user ||= FacebookUser.find(user_id)
    end

    def graph_api
      @graph_api ||= fb_user.graph_api
    end
  end
end

module Controllers
  module FacebookSupport
    CURRENT_PERMISSIONS_LEVEL = 2

    protected
      def require_facebook_permissions
        if current_user
          if signed_request.present? && current_user.oauth_token != signed_request['oauth_token']
            current_user.oauth_token            = signed_request['oauth_token']
            current_user.oauth_token_expires_at = signed_request['expires'] ? Time.at(signed_request['expires']) : nil
            current_user.last_access_at         = Time.now
          end

          if current_user.permissions_level < CURRENT_PERMISSIONS_LEVEL
            unless current_user.check_permissions!
              current_user.save # save off whatever has been updated up to this point
              self.current_user = nil
              render_facebook_login
            end
          end

          if !current_user.global_user? and facebook_global_app?
            current_user.global_user = true
          end

          current_user.save if current_user.changed?

          if current_user.needs_sync?
            Delayed::Job.enqueue(::Jobs::SyncFacebookProfile.new(current_user.id))
          end

          if current_user.last_access_at < 5.minutes.ago
            Delayed::Job.enqueue(::Jobs::UpdateUserRankings.new(current_user.id))
          end

        elsif signed_request.try(:[], 'user_id').present?
          create_facebook_user

        else
          render_facebook_login
        end
      end

      def create_facebook_user
        user = FacebookUser.new
        user.facebook_id = signed_request['user_id']
        user.oauth_token = signed_request['oauth_token']
        user.oauth_token_expires_at = Time.at(signed_request['expires'])
        user.last_facebook_sync_at =  Time.now
        user.last_access_at = Time.now
        user.global_rank = FacebookUser.count
        user.local_rank  = 1
        user.global_user = facebook_global_app?
        user.cash = Settings[:starting_cash].to_i

        profile = user.graph_api.get_object('me')

        user.first_name = profile['first_name']
        user.last_name  = profile['last_name']
        user.link       = profile['link']
        user.username   = profile['username']
        user.email      = profile['email']

        user.save!

        Delayed::Job.enqueue ::Jobs::SyncFacebookProfile.new(user.id)

        FacebookApprequestRecipient.where(facebook_id: user.facebook_id).each do |recipient|
          recipient.user = user
          recipient.save
        end

        self.current_user = user
      end

      def update_facebook_user_data
        if signed_request.present? &&
            (current_user.oauth_token_expires_at.past? ||
            current_user.last_access_at < 5.minutes.ago)

          current_user.oauth_token = signed_request['oauth_token']
          current_user.oauth_token_expires_at = signed_request['expires'] ? Time.at(signed_request['expires']) : nil
          current_user.last_access_at = Time.now
          current_user.save
        end

        Delayed::Job.enqueue(current_user.needs_sync?        ?
            ::Jobs::SyncFacebookProfile.new(current_user.id) :
            ::Jobs::UpdateUserRankings.new(current_user.id)  )
      end

      def facebook_global_app?
        #facebook_app_id is overridden by site controllers
        facebook_app_id == FB[:app_id]
      end

      def facebook_app_url
        FB[:canvas_page]
      end

      def facebook_app_id
        FB[:app_id]
      end

      def facebook_app_secret
        FB[:app_secret]
      end

      def render_facebook_login
        # store request ids into session to process later
        if params[:request_ids]
          session[:request_ids] = (session[:request_ids] || []).concat(params[:request_ids].split(','))
        end

        @oauth_url = oauth.url_for_dialog(:oauth, redirect_uri: facebook_app_url, scope: 'email,read_stream,publish_actions')
        render :template => 'facebook_canvas/login', :layout => false
      end

      def signed_request
        @signed_request ||= params[:signed_request] && oauth.parse_signed_request(params[:signed_request])
      end

      def oauth
        @oauth ||= Koala::Facebook::OAuth.new(facebook_app_id, facebook_app_secret)
      end
  end
end
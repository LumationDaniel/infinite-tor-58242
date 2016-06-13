module Facebook
  module Auth
    class BaseStrategy
      CURRENT_PERMISSIONS_LEVEL = 2

      attr_reader :controller

      def initialize(controller)
        @controller = controller
      end

      def execute
        begin_execute if respond_to? :begin_execute

        if current_user.nil?
          unless authenticate!
            render_facebook_login and return false
          end
        end

        if current_user.permissions_level < CURRENT_PERMISSIONS_LEVEL
          unless current_user.check_permissions!
            current_user.save # save off whatever has been updated up to this point
            self.current_user = nil
            render_facebook_login and return false
          end
        end

        if !current_user.global_user? and facebook_global_app?
          current_user.global_user = true
        end

        before_save_user if respond_to? :before_save_user

        current_user.save if current_user.changed?

        if current_user.needs_sync?
          Delayed::Job.enqueue(::Jobs::SyncFacebookProfile.new(current_user.id))
        end

        if current_user.last_access_at < 5.minutes.ago
          Delayed::Job.enqueue(::Jobs::UpdateUserRankings.new(current_user.id))
        end

        true
      end

      protected
        def render_facebook_login
          url = oauth.url_for_dialog(:oauth, scope: 'email,read_stream,publish_actions')
          controller.instance_variable_set('@redirect_url', url)
          controller.render :template => 'shared/facebook/redirect', :layout => false
        end

        def create_facebook_user(facebook_id, oauth_token, token_expiration)
          user = FacebookUser.new
          user.facebook_id = facebook_id
          user.oauth_token = oauth_token
          user.oauth_token_expires_at = token_expiration
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

        def current_user
          @current_user ||= controller.send :current_user
        end

        def current_user=(user)
          controller.send :current_user=, user
        end

        def facebook_global_app?
          controller.send :facebook_global_app?
        end

        def params
          controller.params
        end

        def facebook_app_id
          FB[:app_id]
        end

        def facebook_app_secret
          FB[:app_secret]
        end

        def facebook_global_app?
          #facebook_app_id is overridden by site controllers
          facebook_app_id == FB[:app_id]
        end

        def oauth
          @oauth ||= Koala::Facebook::OAuth.new(facebook_app_id, facebook_app_secret, oauth_callback_url)
        end
    end
  end
end

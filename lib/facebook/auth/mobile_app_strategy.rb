require 'facebook/auth/base_strategy'

module Facebook
  module Auth
    class MobileAppStrategy < BaseStrategy

      def execute
        success = super

        # redirect so the auth code is removed
        if success and params[:code].present?
          controller.redirect_to controller.url_for(code: nil) and return false
        end

        success
      end

      protected
        def authenticate!
          return false if params[:code].blank?

          if access_token_info
            access_token = access_token_info['access_token']

            api = Koala::Facebook::API.new(access_token)
            profile = api.get_object('me')

            facebook_id = profile['id']
            if user = FacebookUser.find_by_facebook_id(facebook_id)
              self.current_user = user
            else
              create_facebook_user(profile['id'],
                                   access_token,
                                   access_token_info['expires'].to_i.seconds.from_now)
            end
            true
          else
            false
          end
        end

        def oauth_callback_url
          controller.mobile_url
        end

        def access_token_info
          @access_token_info ||= oauth.get_access_token_info(params[:code])
        end

        def begin_execute
          if params[:code]
            # clear current user if given another login code
            self.current_user = nil
          end
        end

        def before_save_user
          if params[:code] and access_token_info
            access_token = access_token_info['access_token']
            expires = access_token_info['expires']

            if access_token and access_token_info['access_token'] != current_user.oauth_token
                expires and expires.to_i.seconds.from_now.to_i != current_user.oauth_token_expires_at.to_i
              current_user.oauth_token = access_token
              current_user.oauth_token_expires_at = expires.to_i.seconds.from_now
              current_user.last_access_at = Time.now
            end
          end
        end

    end
  end
end

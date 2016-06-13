require 'facebook/auth/mobile_app_strategy'

module Mobile
  class GamesController < Pickoff::GamesController

    before_filter :require_facebook_auth
    layout 'mobile'

    protected
      def require_facebook_auth
        auth_strategy.execute
      end

      def auth_strategy
        @auth_strategy ||= Facebook::Auth::MobileAppStrategy.new(self)
      end
  end
end

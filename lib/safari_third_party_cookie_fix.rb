# http://stackoverflow.com/a/14194677/10053
module SafariThirdPartyCookieFix
  extend ActiveSupport::Concern

  included do
    before_filter :safari_cookie_fix
  end

  def safari_cookie_fix
    user_agent = UserAgent.parse(request.user_agent)
    if user_agent.browser == 'Safari'
      return if session[:safari_cookie_fixed]
      if params[:safari_cookie_fix].present?
        session[:safari_cookie_fixed] = true
        redirect_to params[:return_to]
      else
        render text: <<-HTML
          <script>top.window.location='?safari_cookie_fix=true&return_to=#{facebook_app_url}/';</script>"
        HTML
      end
    end
  end

end

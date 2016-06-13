require 'daily_bonus'
require 'safari_third_party_cookie_fix'

class Fb::GamesController < Pickoff::GamesController
  include DailyBonus
  include SafariThirdPartyCookieFix

  skip_before_filter :verify_authenticity_token
  before_filter :require_facebook_permissions
  before_filter :reward_daily_bonus
  before_filter :process_request, :only => :upcoming

  protected
    def process_request
      request_ids = []

      puts "params request_ids: #{params[:request_ids].inspect}"
      if params[:request_ids]
        request_ids.concat(params[:request_ids].split(','))
      end

      puts "session request_ids: #{session[:request_ids].inspect}"
      if session[:request_ids]
        request_ids.concat(session[:request_ids])
        session[:request_ids] = nil
      end

      redirect_to fb_requests_path(request_ids: request_ids.join(',')) if request_ids.any?
    end

end

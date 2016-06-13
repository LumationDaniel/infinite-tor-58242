require 'daily_bonus'

class FacebookCanvasController < ApplicationController
  include DailyBonus
  include ActionView::Helpers::NumberHelper

  skip_before_filter :verify_authenticity_token

  before_filter :require_facebook_permissions
  #before_filter :reward_daily_bonus
end

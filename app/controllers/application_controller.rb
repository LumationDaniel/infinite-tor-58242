require 'jobs/sync_facebook_profile'
require 'jobs/update_user_rankings'
require 'controllers/facebook_support'

class ApplicationController < ActionController::Base
  include Controllers::FacebookSupport

  protect_from_forgery
  helper :bootstrap

  before_filter :rotate_announcement_index

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

protected
  helper_method :facebook_app_url, :facebook_app_id, :signed_request

  def rotate_announcement_index
    # POST for facebook canvas requests
    if !request.xhr? && ((request.get? && current_user.present?) || (request.post? && (current_user.present? || params[:signed_request].present?)))
      session[:ann] = if session[:ann].present?
        (session[:ann].to_i + 1).to_s
      else
        "0"
      end
    end
  end

  def current_user=(user)
    @user = user
    session[:user_id] = user.try :id
  end

  def current_user
    @user ||= session[:user_id] && FacebookUser.find_by_id(session[:user_id])
    if @user.nil? && signed_request.try(:[], 'user_id').present?
      if u = FacebookUser.facebook_id(signed_request['user_id'])
        self.current_user = u
      end
    end
    # if @user and @user.id == 1
    #   @user = FacebookUser.find_by_id(503)
    # end
    @user
  end
  helper_method :current_user

  def me?(user)
    current_user == user
  end
  helper_method :me?

  def add_session_notice key, notice
    (session[:notices] ||= {})[key] = notice
  end

  def clear_session_notice key
    if session[:notices]
      session[:notices].delete key
      session[:notices] = nil if session[:notices].keys.count == 0
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_admin_user)
  end
end

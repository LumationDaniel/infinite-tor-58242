class UnsubscribesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create
  before_filter :verify_action_token

  layout 'standalone'

  def create
    @notification = Notification.find(params['n'])
    target_user.unsubscribe_from_notification(@notification)
    flash.now[:notice] = "#{target_user.email} unsubscribed from '#{@notification.description}'."
  end

  def destroy
    @notification = Notification.find(params[:id])
    target_user.subscribe_to_notification(@notification)
    flash.now[:notice] = "Re-subscribed #{target_user.email} to '#{@notification.description}'."
  end

  protected
    def target_user
      @target_user ||= FacebookUser.find params['u']
    end
    helper_method :target_user

    def verify_action_token
      unless target_user.verify_action(params['t'],
                                       action_name == 'create' ? :unsubscribe : :subscribe,
                                       {
                                         'u' => params['u'],
                                         'n' => params[:id] || params['n']
                                       })
        render status: :not_authorized, text: 'Not Authorized'
      end
    end
end

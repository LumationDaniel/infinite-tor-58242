class AlertsController < ApplicationController

  def destroy
    alert_type, alert_id = params[:id].split(':')
    case alert_type
    when 'announcement'
      if current_user && !current_user.user_announcements.read.where(announcement_id: params[:id]).exists?
        ann = current_user.user_announcements.build
        ann.announcement_id = alert_id
        ann.read_on = Time.now
        ann.save!
      end
    when 'session_notice'
      clear_session_notice alert_id.to_sym
    else
      return render status: :not_found, nothing: true
    end

    render status: :ok, nothing: true
  end

end

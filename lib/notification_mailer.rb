require 'controllers/facebook_support'

module NotificationMailer
  def self.included(base)
    base.send :include, Controllers::FacebookSupport
    base.send :include, FacebookCanvasHelper
    base.send :include, Rails.application.routes.url_helpers
    base.send :extend, ClassMethods

    base.class_attribute :default_url_options
    base.default_url_options = ActionMailer::Base.default_url_options
  end

  module ClassMethods
    def register_notification(name, method)
      notification = Notification.
          provider_and_method(self.name, method).
          first_or_create({name: name}, without_protection: true)
      notification.name = name
      notification.save! if notification.name_changed?
    end

    def deliver_if_subscribed(user, method, *args)
      notification = Notification.provider_and_method(self.name, method).first
      if user.subscribed_to_notification?(notification)
        self.send(method, *args).deliver
      end
    end
  end

  protected

    def subject_for(method_name, default_subject, opts = {})
      subject = notification(method_name).try(:subject)
      (subject.blank? ? default_subject : subject) % opts
    end

    def recipient(user)
      { email: user.email, name: user.full_name }
    end

    def global_merge_vars(method_name, user, *vars)
      [

        { name: 'UNSUB', content: unsubscribe_url_for(method_name, user) },
        { name: 'UPDATE_PROFILE', content: 'http://play.pickoffsports.com/profile' },
        { name: 'CURRENT_YEAR', content: Date.today.year.to_s },
        { name: 'COMPANY', content: Settings.company_name },
        { name: 'ADDRESS_HTML', content: address_html }

      ].concat vars
    end

    def notification(method)
      Notification.provider_and_method(self.class.name, method).first
    end

    def unsubscribe_url_for(method_name, user)
      params = {
        'u' => user.id,
        'n' => notification(method_name).id
      }
      params['t'] = user.sign_action(:unsubscribe, params)
      qs = params.map { |(k,v)| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')

      unsubscribes_url(params)
    end

    def address_html
      [
        Settings[:company_name],
        Settings[:address],
        "#{Settings[:city]}, #{Settings[:state]} #{Settings[:postal_code]}"
      ].join('<br>').html_safe
    end
end

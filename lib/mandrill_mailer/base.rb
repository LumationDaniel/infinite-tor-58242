module MandrillMailer
  class Base
    class_attribute :default_params
    self.default_params = {
      template_content: []
    }

    class_attribute :mandrill_api_key

    def mail(params)
      unless Rails.env.production?
        params[:template_name] = "#{params[:template_name]} - #{Rails.env.titleize}"
      end
      params.deep_merge(self.class.default_params)
    end

    class << self
      def api_key(api_key)
        self.mandrill_api_key = api_key if api_key
        mandrill_api_key
      end

      def default(value = nil)
        self.default_params = default_params.merge(value).freeze if value
        default_params
      end

      def method_missing(method, *args) #:nodoc:
        Message.new(Mandrill::API.new(self.mandrill_api_key), new.send(method, *args))
      end
    end
  end

  class Message
    def initialize(api, params)
      @api = api
      @params = params
    end

    def deliver
      @api.messages 'send-template', @params
    end
  end
end

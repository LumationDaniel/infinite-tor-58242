module Controllers
  module FacebookCanvasSupport
    def self.included(base)
      base.skip_before_filter :verify_authenticity_token
      base.before_filter :require_facebook_permissions
    end
  end
end
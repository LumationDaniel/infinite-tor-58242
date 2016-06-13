require 'controllers/facebook_canvas_support'

module Sites
  module Facebook
    class BaseController < ApplicationController
      include Controllers::FacebookCanvasSupport

      protected
        def require_facebook_permissions
          super
          if current_user
            unless current_user.sites.include?(site)
              current_user.sites << site
            end
          end
        end

        def site
          @site ||= Site.find_by_permalink(params[:site])
        end
        helper_method :site

        def facebook_app_id
          site.facebook_app_id
        end

        def facebook_app_secret
          site.facebook_app_secret
        end

        def facebook_app_url
          site.facebook_app_url
        end
    end
  end
end
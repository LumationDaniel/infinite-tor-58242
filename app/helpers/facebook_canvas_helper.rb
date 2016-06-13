module FacebookCanvasHelper
  def fb_app_url(path = '/')
    path = "/#{path}" unless path.starts_with? '/'
    "#{facebook_app_url}#{path}"
  end

  def fb_link_to(text, path = '', opts = {})
    link_to(text, fb_app_url(path), {target: '_top'}.merge(opts))
  end

  def fb_init
    content_tag(:div, '', :id => 'fb-root') +
    javascript_include_tag('https://connect.facebook.net/en_US/all.js') +
    javascript_tag do
      (<<-JAVASCRIPT
FB.init({
    appId  : '#{facebook_app_id}',
    status : false,
    cookie : true,
    oauth  : true,
    xfbml  : true
});
      JAVASCRIPT
     ).html_safe
    end
  end
end

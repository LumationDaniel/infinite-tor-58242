module BootstrapHelper

  def bootstrap_alert(alert_level, message, opts = {})
    content_tag(:div, {class: "alert-message #{alert_level}"}.merge(opts)) do
      [content_tag(:a, 'x', class: 'close', href: '#'), content_tag(:p, message)].join.html_safe
    end
  end

  def bootstrap_tab_item(label, is_active = false)
    content_tag(:li, label, class: (is_active ? 'active' : nil))
  end

end

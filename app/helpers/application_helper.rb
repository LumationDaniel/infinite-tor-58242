module ApplicationHelper

  def show_announcement
    unless @announcement
      announcements = (respond_to?(:site) ? site.announcements : Announcement).active.prioritized
      announcements = announcements.unread_by(current_user) if current_user
      if announcements.present?
        ann_index = ((session[:ann] || 0).to_i % announcements.length)
        @announcement = announcements[ann_index]
        bootstrap_alert(:info, escape_once(@announcement.message).html_safe,
                        class: 'alert-message block-message info',
                        'data-announcement-id' => @announcement.id)
      end
    end
  end

  def add_session_notices
    return unless session[:notices].present?
    session[:notices].map { |(k,v)| javascript_tag "Pickoff.addNotice('#{k}')" }.join("\n").html_safe
  end

  def fb_profile_pic(user)
    fb_id = user.kind_of?(FacebookUser) ? user.facebook_id : user.to_s
    fb_name = user.kind_of?(FacebookUser) ? user.anonymous_name : user.to_s
    image_tag("https://graph.facebook.com/#{fb_id}/picture", :alt=>fb_name, :title=>fb_name)
  end

  def page_id(id)
    @page_id = id.to_s
  end

  def local_leaderboard
    @local_leaderboard ||= begin
      select = %w(id first_name last_name facebook_id).map do |v|
        "#{FacebookUser.quoted_table_name}.#{v}"
      end

      select << "COALESCE(earnings.total,0) AS total_earnings"

      query = FacebookUser.select(select.join(', '))

      now = Time.zone.now
      earnings_subquery = CashActivity.earnings.
          select('user_id, SUM(amount) AS total').
          joins(:game).
          where("starts_at BETWEEN ? AND ?", now - 30.days, now).
          group('user_id')

      join_sql = <<-JOIN_SQL
        LEFT OUTER JOIN (#{earnings_subquery.to_sql}) earnings
        ON earnings.user_id = #{FacebookUser.quoted_table_name}.id
      JOIN_SQL

      query.
        joins(join_sql).
        where("#{FacebookUser.quoted_table_name}.id" => current_user.friend_ids.to_a << current_user.id).
        order('total_earnings DESC')
    end
  end

  def league_select(leagues, selected = nil)
    output = [link_to(selected.try(:label) || 'Select Sport', '#', :class => 'select sport')]
    output << content_tag(:ul, :class => 'select-list sport') do
      content_tag(:li) do
        link_to 'Show All', yield(:all), target: '_top'
      end +
      leagues.collect do |league|
        content_tag(:li) do
          link_to league.label, yield(league), target: '_top'
        end
      end.join.html_safe
    end
    output.join.html_safe
  end
end

require 'mandrill_mailer/base'
require 'notification_mailer'

class ReEngagementMailer < MandrillMailer::Base
  include NotificationMailer
  include ActionView::Helpers::NumberHelper

  register_notification 'Re-Engagement', :re_engagement

  api_key ENV['MANDRILL_PASSWORD']

  default message: {
            from_email: "mailer@pickoffsports.com",
            from_name: "Pickoff Sports"
          }

  def re_engagement(user)
    games_by_date = Game.live.where(['starts_at > ?', Time.now]).limit(5).group_by { |g| g.starts_at.to_date }
    preview = []
    games_by_date.keys.sort.each_with_index do |date, index|
      preview << '<br>' if index > 0
      preview << "<span style=\"font-size:x-large\"><b>#{date.today? ? 'Today' : date.to_s(:long)}</b></span>"

      games_by_date[date].each do |game|
        preview << "<span style=\"font-size:large\"><b>#{game.name.present? ? game.name : game.league.label}:</b> #{game.away_team.name} vs #{game.home_team.name}</span>"
      end
    end

    mail( template_name: 'Re-Engagement',
          message: {
            to: [ recipient(user) ],
            subject: subject_for(:re_engagement, "We miss you! Here's are some upcoming picks for you"),
            global_merge_vars: global_merge_vars(:re_engagement, user,
              { name: 'GAMES_PREVIEW', content: preview.join('<br>') }
            )
          },
          tags: ['Re-Engagement'])
  end
end


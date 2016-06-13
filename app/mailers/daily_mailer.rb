require 'mandrill_mailer/base'
require 'notification_mailer'

class DailyMailer < MandrillMailer::Base
  include NotificationMailer
  include ActionView::Helpers::NumberHelper

  register_notification 'Daily Update', :daily_update

  api_key ENV['MANDRILL_PASSWORD']

  default message: {
            from_email: "mailer@pickoffsports.com",
            from_name: "Pickoff Sports"
          }

  def daily_update(user)
    date = Time.now.in_time_zone('America/New_York').yesterday.beginning_of_day

    picks = user.pickem_entries.
      joins(:game).
      where(["#{Game.quoted_table_name}.starts_at >= ? AND #{Game.quoted_table_name}.completed = ?", date, true])

    results = picks.map do |pick|
      if pick.win?
        "<span style=\"font-style:large\"><b>WIN:</b> #{pick.game.away_team.name} #{pick.game.away_score}, #{pick.game.home_team.name} #{pick.game.home_score}, #{number_to_currency(pick.game.cash_prize, precision: 0)}</span>"
      elsif pick.game.tie?
        "<span style=\"font-style:large\"><b>TIE:</b> #{pick.game.away_team.name} #{pick.game.away_score}, #{pick.game.home_team.name} #{pick.game.home_score}</span>"
      else
        "<span style=\"font-style:large\"><b>LOST:</b> #{pick.game.away_team.name} #{pick.game.away_score}, #{pick.game.home_team.name} #{pick.game.home_score}, #{number_to_currency(pick.game.cash_penalty_for_loss, precision: 0)}</span>"
      end
    end

    games_by_date = Game.live.where(['starts_at > ?', Time.now]).limit(5).group_by { |g| g.starts_at.to_date }
    preview = []
    games_by_date.keys.sort.each_with_index do |date, index|
      preview << '<br>' if index > 0
      preview << "<span style=\"font-size:x-large\"><b>#{date.today? ? 'Today' : date.to_s(:long)}</b></span>"

      games_by_date[date].each do |game|
        preview << "<span style=\"font-size:large\"><b>#{game.name.present? ? game.name : game.league.label}:</b> #{game.away_team.name} vs #{game.home_team.name}</span>"
      end
    end

    mail( template_name: 'Daily Update',
          message: {
            to: [ recipient(user) ],
            subject: subject_for(:daily_update, "Here's how your picks did yesterday"),
            global_merge_vars: global_merge_vars(:daily_update, user,
              { name: 'DATE', content: Time.now.in_time_zone('America/New_York').to_date.to_s(:long) },
              { name: 'RESULTS', content: results.join('<br>') },
              { name: 'GAMES_PREVIEW', content: preview.join('<br>') }
            )
          },
          tags: ['Daily Update']
    )
  end
end


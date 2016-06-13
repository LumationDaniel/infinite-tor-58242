require 'mandrill_mailer/base'
require 'notification_mailer'

class DailySiteMailer < MandrillMailer::Base
  include NotificationMailer
  include ActionView::Helpers::NumberHelper

  register_notification 'Daily Update', :daily_update

  api_key ENV['MANDRILL_PASSWORD']

  default message: {
            from_email: "mailer@pickoffsports.com",
            from_name: "Pickoff Sports"
          }

  def daily_update(site, user)
    date = Time.now.in_time_zone('America/New_York').yesterday.beginning_of_day

    answers = user.answers.joins(<<-SQL
      INNER JOIN #{Question.quoted_table_name} q
        ON q.id = #{UserAnswer.quoted_table_name}.question_id
        AND q.site_id = #{site.id}
        AND q.locked_on >= '#{date.beginning_of_day.to_s(:db)}'
        AND q.completed_on IS NOT NULL
    SQL
    )

    results = answers.map do |answer|
      <<-HTML
        <span style="font-style:large">
          <b>#{answer.correct? ? 'CORRECT:' : 'INCORRECT:'}</b>
          #{answer.question.text} <em>Answer: #{answer.question.right_answer.text}</em>,
          #{number_to_currency(answer.cash_result, precision: 0)}
        </span>
      HTML
    end

    questions_by_date = site.questions.live.where(['locked_on > ?', Time.now]).limit(5).group_by { |g| g.locked_on.to_date }
    preview = []
    questions_by_date.keys.sort.each_with_index do |date, index|
      preview << '<br>' if index > 0
      preview << "<span style=\"font-size:x-large\"><b>#{date.today? ? 'Today' : date.to_s(:long)}</b></span>"

      questions_by_date[date].each do |question|
        preview << "<span style=\"font-size:large\">#{question.text}</span>"
      end
    end

    mail( template_name: 'Daily Site Update',
          message: {
            to: [ recipient(user) ],
            subject: subject_for(:daily_update, "Here's how well your answers did yesterday"),
            global_merge_vars: global_merge_vars(:daily_update, user,
              { name: 'DATE', content: Time.now.in_time_zone('America/New_York').to_date.to_s(:long) },
              { name: 'RESULTS', content: results.join('<br>') },
              { name: 'QUESTIONS_PREVIEW', content: preview.join('<br>') }
            )
          },
          tags: ['Daily Site Update']
    )
  end
end


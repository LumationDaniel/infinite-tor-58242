module Jobs
  class DailySiteUpdate
    attr_accessor :date_time, :site

    def initialize(site, date_time)
      self.site = site
      self.date_time = date_time
    end

    def perform
      return unless had_completed_questions?
      target_user_ids.each do |user_id|
        report_exception do
          u = FacebookUser.find(user_id)
          DailySiteMailer.deliver_if_subscribed(u, :daily_update, site, u)
        end
      end
    end

    def target_user_ids
      @target_user_ids ||= site.users.select("DISTINCT #{FacebookUser.quoted_table_name}.id").joins(<<-SQL
        INNER JOIN #{UserAnswer.quoted_table_name} AS ua
          ON ua.user_id = #{FacebookUser.quoted_table_name}.id
        INNER JOIN #{Question.quoted_table_name} AS q
          ON q.id = ua.question_id
          AND q.locked_on >= '#{date_time.beginning_of_day.to_s(:db)}'
          AND q.completed_on IS NOT NULL
      SQL
      )
    end

    def had_completed_questions?
      site.questions.completed_on_date(date_time).exists?
    end

    def self.perform
      report_exception do
        yesterday = Time.now.in_time_zone('America/New_York').yesterday
        Site.find_each do |site|
          DailySiteUpdate.new(site, yesterday).perform
        end
      end
    end

  end
end

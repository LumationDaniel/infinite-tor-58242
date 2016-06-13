module Jobs
  class DailyUpdate
    def self.perform
      report_exception do
        where_condition = <<-SQL
          #{Game.quoted_table_name}.starts_at >= ?
          AND #{Game.quoted_table_name}.completed = ?
          AND #{FacebookUser.quoted_table_name}.global_user = #{ActiveRecord::Base.connection.quoted_true}
        SQL
        yesterday = Time.now.in_time_zone('America/New_York').yesterday
        join = FacebookUser.select("DISTINCT #{FacebookUser.quoted_table_name}.id").
                            joins(pickem_entries: :game).
                            where([where_condition, yesterday.beginning_of_day, true])
        users = FacebookUser.joins("INNER JOIN (#{join.to_sql}) b ON b.id = #{FacebookUser.quoted_table_name}.id")
        users.each do |u|
          report_exception do
            DailyMailer.deliver_if_subscribed(u, :daily_update, u)
          end
        end
      end
    end
  end
end

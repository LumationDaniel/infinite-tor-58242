module Jobs
  class ReEngagement
    def self.perform
      report_exception do
        re_engagement_cut_off = (Time.now.in_time_zone('America/New_York') - 7.days).beginning_of_day
        join = FacebookUser.select("#{FacebookUser.quoted_table_name}.id").
                            joins(:pickem_entries).
                            where(["#{FacebookUser.quoted_table_name}.global_user = ?", true]).
                            group("#{FacebookUser.quoted_table_name}.id").
                            having(["MAX(#{PickemEntry.quoted_table_name}.created_at) < ?",
                                    re_engagement_cut_off])
        users = FacebookUser.joins("INNER JOIN (#{join.to_sql}) b ON b.id = #{FacebookUser.quoted_table_name}.id")
        users.each do |u|
          report_exception do
            ReEngagementMailer.deliver_if_subscribed(u, :re_engagement, u)
          end
        end
      end
    end
  end
end

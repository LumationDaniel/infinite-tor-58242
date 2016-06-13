class Fb::LeaderboardsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  def index
    build_leaderboard
  end

  def show
    @game_group = GameGroup.find_by_permalink(params[:id])
    build_leaderboard
  end

  protected
    def build_leaderboard
      select = %w(id first_name last_name facebook_id).map do |v|
        "#{FacebookUser.quoted_table_name}.#{v}"
      end

      select << "COALESCE(earnings.total,0) AS total_earnings"
      select << "COALESCE(picks.total, 0) AS picks_total"
      select << "COALESCE(wins.total, 0) AS total_wins"
      select << "CASE WHEN picks.total >= 20 THEN (CAST(COALESCE(wins.total,0) AS decimal)/picks.total) ELSE 0 END AS accuracy"
      select << "COALESCE(friends.total, 0) AS total_friends"

      @users = FacebookUser.select(select.join(', '))

      joins = {
        earnings: CashActivity.earnings.select('user_id, SUM(amount) AS total').group('user_id'),
           picks: PickemEntry.select("user_id, COUNT(#{PickemEntry.quoted_table_name}.id) AS total").group('user_id'),
            wins: PickemEntry.wins.select("user_id, COUNT(#{PickemEntry.quoted_table_name}.id) AS total").group('user_id'),
         friends: Friendship.select('user_id, COUNT(id) AS total').group('user_id')
      }

      @time_filter = params[:time].blank? ? '30days' : params[:time]
      if @time_filter == '30days'
        joins.keys.each do |k|
          joins[k] = if k == :picks || k == :wins
            joined_to_games = true
            joins[k].joins(:game).where("starts_at BETWEEN ? AND ?", 30.days.ago, Time.now)
          else
            joins[k].where(created_at: [30.days.ago..Time.now])
          end
        end
      end

      if @game_group
        joins.keys.each do |key|
          if key != :friends
            joins[key] = joins[key].joins(:game).where("#{Game.quoted_table_name}.group_id = ?", @game_group.id)
          end
        end

        @users = @users.where('COALESCE(picks.total, 0) > 0')
      end

      join_sql = joins.map do |(k,v)|
        <<-JOIN_SQL
          LEFT OUTER JOIN (#{v.to_sql}) #{k} ON #{k}.user_id = #{FacebookUser.quoted_table_name}.id
        JOIN_SQL
      end

      @users = @users.joins(join_sql.join(' '))

      @people_filter = params[:people].blank? ? 'all' : params[:people]
      if @people_filter == 'friends' && current_user
        @users = @users.where("#{FacebookUser.quoted_table_name}.id" => current_user.friend_ids.to_a << current_user.id)
      end

      if @time_filter == '30days'
        @users = @users.where('picks.total IS NOT NULL')
      end

      @sort = params[:sort].blank? ? 'earnings' : params[:sort]
      @sort_direction, sort_direction_sql = if params[:sort_direction] == 'a'
        ['a', 'ASC']
      else
        ['d', 'DESC']
      end

      @users = case @sort
      when 'accuracy'
        @users.order("case when picks.total >= 20 then 0 else 1 end, accuracy #{sort_direction_sql}")
      when 'picks'
        @users.order("picks_total #{sort_direction_sql}")
      when 'friends'
        @users.order("total_friends #{sort_direction_sql}")
      else
        @users.order("total_earnings #{sort_direction_sql}")
      end

      @users = @users.page(page).per(per_page)
    end

    def page; (params[:p] || 1).to_i; end
    def per_page; 20; end
    helper_method :page, :per_page

    def leaderboard_game_groups
      @leaderboard_game_groups ||= DisplayOrder.leaderboard.map(&:target)
    end
    helper_method :leaderboard_game_groups

end

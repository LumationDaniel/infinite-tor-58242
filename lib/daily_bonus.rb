module DailyBonus

  protected

    def reward_daily_bonus
      return unless current_user.award_daily_bonus?

      current_user.touch(:daily_bonus_last_awarded_on)

      v = rand
      award = if v < 0.2
        50
      elsif v < 0.55
        100
      elsif v < 0.85
        200
      else
        500
      end

      if current_user.likes_app_page?
        bonus_percentage = Settings[:daily_bonus_like_bonus_percentage].to_f
        award_with_bonus = award + (award * bonus_percentage)
        current_user.update_cash!(award_with_bonus, 'daily_with_like_bonus')
        add_session_notice "daily_bonus_#{award}_with_like_bonus".to_sym, ''
      else
        current_user.update_cash!(award, 'daily_bonus')
        add_session_notice "daily_bonus_#{award}".to_sym, ''
      end
    end

end

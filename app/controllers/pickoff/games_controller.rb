
module Pickoff
  class GamesController < ApplicationController

    def upcoming
      @league = League.find(params[:id]) if params[:id].present?
      @games  = (@league ? @league.games : Game).
                    live.
                    upcoming.
                    user(current_user).
                    includes(:group => :league).
                    where("pickem_entries.winner_id IS NULL").
                    order('starts_at ASC')
    end

    def picks
      @league = League.find(params[:id]) if params[:id].present?
      @games  = (@league ? @league.games : Game).
                    live.
                    upcoming.
                    user(current_user).
                    includes(:group => :league).
                    where("pickem_entries.winner_id IS NOT NULL").
                    order('starts_at ASC')
    end

    def completed
      @league = League.find(params[:id]) if params[:id].present?
      @games  = (@league ? @league.games : Game).
                    recently_past.
                    user(current_user).
                    includes(:group => :league).
                    where("pickem_entries.winner_id IS NOT NULL").
                    order('starts_at DESC')
    end

  end
end

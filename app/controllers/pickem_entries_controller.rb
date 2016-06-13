class PickemEntriesController < ApplicationController
  def create
    game_ids = params.keys.collect do |name|
      m = name.match(/game_(\d+)/)
      m ? m[1].to_i : nil
    end.compact

    entries = PickemEntry.user(current_user).games(game_ids).all(include: :game)
    entries.each do |entry|
      entry.winner_id = params["game_#{entry.game.id}"].to_i
      entry.save
      game_ids.delete(entry.game.id)
    end

    games = Game.ids(game_ids)
    games.each do |game|
      entry = current_user.pickem_entries.build
      entry.game = game
      entry.winner_id = params["game_#{game.id}"].to_i
      entry.save
    end

    redirect_to fb_path
  end

  def update
    respond_to do |f|
      f.text do
        if current_user
          current_user.make_pick!(
              Game.find(params[:id]),
              Team.find(params[:pickem_entry][:winner_id]))
          render status: 200, nothing: true
        else
          render status: 401, nothing: true
        end
      end
    end
  end

end

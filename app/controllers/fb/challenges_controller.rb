class Fb::ChallengesController < ApplicationController

  skip_before_filter :verify_authenticity_token

  before_filter :require_facebook_permissions
  before_filter :ensure_challenge_opponent, only: [ :accept, :decline ]

  def index
    @outgoing_challenges = current_user.outgoing_challenges.active
    @incoming_challenges = current_user.incoming_challenges.accepted
  end

  def show
    respond_to do |f|
      f.json do
        # get the available cash of the opponent - can't wager
        # more than what the user can offer.
        opponent = FacebookUser.facebook_id(params['opponent_fb_id'])
        opponent_cash = opponent.try(:accessible_cash) || Settings[:starting_cash].to_i

        render json: {
          'opponent_accessible_cash' => opponent_cash,
          'accessible_cash'          => current_user.accessible_cash
        }
      end
      f.html do
        @challenge = Challenge.find(params[:id])
      end
    end
  end

  def update
    entry = current_user.pickem_entries.for_game(params[:id]).includes(:game).first

    # this first condition is broken
    if challenge = entry.outgoing_challenges.facebook_id(params['opponent_fb_id']).first
      challenge.wager_amount = params[:wager_amount]
      create_challenge_request(challenge) if challenge.save!

    else
      opponent = FacebookUser.facebook_id(params['opponent_fb_id'])

      challenge = entry.outgoing_challenges.build
      challenge.wager_amount = params[:wager_amount]
      challenge.opponent = opponent

      if challenge.save!
        create_challenge_request(challenge)
        challenge.send_challenge_notice
      end
    end

    entry.reload
    respond_to do |f|
      f.json do
        render json: {
          'challenges' => entry.challenges_count,
          'total_challenges' => current_user.active_challenges_count
        }
      end
    end
  end

  def accept
    @challenge.accept! if @challenge.open?
    respond_to do |f|
      f.json { render json: { 'total_challenges' => current_user.active_challenges_count } }
      f.html { redirect_to fb_challenge_path(@challenge) }
    end
  end

  def decline
    @challenge.decline! if @challenge.open?
    respond_to do |f|
      f.json { render status: 200, json: 'OK' }
      f.html { redirect_to fb_challenge_path(@challenge) }
    end
  end

  protected

    def ensure_challenge_opponent
      @challenge = Challenge.find(params[:id])
      unless me? @challenge.opponent
        render status: 403, nothing: true
      end
    end

    def create_challenge_request(challenge)
      req = FacebookApprequest.new
      req.request_type = 'challenge'
      req.request_id   =  params[:request_id]
      req.target       =  challenge
      req.user         =  current_user
      req.save

      recipient = req.request_recipients.build
      recipient.user = challenge.opponent
      recipient.name = params['opponent_name']
      recipient.facebook_id = params['opponent_fb_id']
      recipient.save

      req
    end
end

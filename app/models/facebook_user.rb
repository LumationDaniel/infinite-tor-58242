require 'openssl'

class FacebookUser < ActiveRecord::Base
  has_many :pickem_entries, foreign_key: 'user_id', dependent: :destroy
  has_many :outgoing_challenges, through: :pickem_entries do
    def wagered_cash
      where("state in ('open', 'accepted')").sum('wager_amount')
    end
  end
  has_many :incoming_challenges, foreign_key: 'opponent_id', class_name: 'Challenge' do
    def wagered_cash
      where("state in ('accepted')").sum('wager_amount')
    end
  end

  has_many :answers, class_name: 'UserAnswer', foreign_key: 'user_id'

  has_many :friendships, foreign_key: 'user_id', dependent: :destroy
  has_many :friends    , through: :friendships, source: :other_user

  # setting up this association only for dependent: :destroy
  has_many :inverse_friendships, foreign_key: 'other_user_id', class_name: 'Friendship', dependent: :destroy

  has_many :user_announcements, foreign_key: 'user_id', dependent: :destroy
  has_many :cash_activities, foreign_key: 'user_id', dependent: :destroy
  has_many :notification_preferences, foreign_key: 'user_id', dependent: :destroy

  has_many :user_sites, foreign_key: 'user_id', dependent: :destroy
  has_many :sites, through: :user_sites

  scope :registered_on_day   , lambda { |day| where(created_at: day.beginning_of_day..day.end_of_day) }
  scope :registered_today    , lambda { registered_on_day(Date.today) }
  scope :registered_yesterday, lambda { registered_on_day(Date.yesterday) }

  # This is a hack so that we can filter by users by site
  scope :site_eq, lambda { |s| joins(:sites).where(sites: { id: s.to_param }) }
  search_methods :site_eq

  before_validation :generate_secret_token
  after_create :record_starting_cash
  around_save :update_subscription

  def self.facebook_id(id)
    where(:facebook_id => id).first
  end

  def friends_count
    read_attribute(:friendships_count)
  end

  def active_challenges_count
    outgoing_challenges.active.count + incoming_challenges.accepted.count
  end

  def accessible_cash
    cash - outgoing_challenges.wagered_cash - incoming_challenges.wagered_cash
  end

  def friends_with?(user)
    friends.include?(user)
  end

  def anonymous_name
    "#{first_name} #{last_name[0]}"
  end

  def graph_api
    Koala::Facebook::API.new(oauth_token)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def valid_access_token?
    oauth_token? && !oauth_token_expires_at.try(:past?)
  end

  def needs_sync?
    !last_facebook_sync_at? || last_facebook_sync_at < 30.minutes.ago || !email?
  end

  def award_daily_bonus?
    !created_at.today? && (
      daily_bonus_last_awarded_on.nil? ||
      daily_bonus_last_awarded_on < Time.now.in_time_zone('America/New_York').beginning_of_day
    )
  end

  def total_picks
    wins + loses
  end

  def pickem_accuracy
    total_picks > 0 ? (wins.to_f / total_picks) * 100 : 0
  end

  def make_pick!(game, winner)
    entry = pickem_entries.for_game(game).first

    if entry.nil?
      entry = pickem_entries.build
      entry.game = game
    end

    entry.winner = winner
    entry.save!
    entry
  end

  def answer_question!(answer)
    ans = answers.for_question(answer.question).first || answers.build
    ans.answer = answer
    ans.save!
    ans
  end

  def update_rankings!
    self.global_rank = FacebookUser.count - FacebookUser.where('cash <= ? AND id <> ?', cash, id).count
    self.local_rank  = friends.count - friends.where('cash <= ?', cash).count + 1
    save(validate: false)
  end

  def update_cash!(amount, activity_code, source = nil, options = {})
    self.class.update_counters(self.id, cash: amount)
    cash_activity = cash_activities.build
    cash_activity.amount = amount
    cash_activity.code = activity_code
    cash_activity.source = source
    cash_activity.game = source.game if source.respond_to?(:game)
    cash_activity.question = source.question if source.respond_to?(:question)
    cash_activity.description = options[:description]
    cash_activity.save
  end

  def check_permissions!
    if permissions_level == 0
      profile = graph_api.get_object('me')
      if profile['email']
        self.email = profile['email']
        self.permissions_level = 1
      end
    end

    if permissions_level == 1
      resp = graph_api.fql_query("select read_stream from permissions where uid = '#{facebook_id}'")
      self.permissions_level = 2 if resp.first['read_stream'] == 1
    end
  end

  def check_likes_app_page
    resp = graph_api.fql_query("select page_id from page_fan where uid = '#{facebook_id}' and page_id = '#{FB[:page_id]}'")
    self.likes_app_page = resp.any?
  end

  def subscribe
    g = Gibbon.new(ENV['MAILCHIMP_API_KEY'])
    g.list_subscribe(
      id: ENV['MAILCHIMP_LIST_ID'],
      email_address: email,
      send_welcome: true,
      merge_vars: {
        'FNAME' => first_name,
        'LNAME' => last_name
      }
    )
  end

  def safe_subscribe
    report_exception { subscribe }
  end

  def subscribed_to_notification?(notification)
    !notification_preferences.where(
      [
        "notification_id = ? AND unsubscribed_on IS NOT NULL",
        notification.id
      ]
    ).exists?
  end

  def unsubscribe_from_notification(notification)
    if pref = notification_preferences.for_notification(notification).first
      if pref.subscribed?
        pref.touch(:unsubscribed_on)
      end
    else
      notification_preferences.create({
        notification: notification,
        unsubscribed_on: Time.now
      }, without_protection: true)
    end
  end

  def subscribe_to_notification(notification)
    if pref = notification_preferences.for_notification(notification).first
      unless pref.subscribed?
        pref.unsubscribed_on = nil
        pref.save
      end
    end
  end

  # http://www.intridea.com/blog/2012/6/7/signed-idempotent-action-links
  # http://blog.jcoglan.com/2012/06/09/why-you-should-never-use-hash-functions-for-message-authentication/
  def sign_action(action, params)
    values = params.keys.sort.map { |k| params[k] }
    string = "--signed-#{action}=#{values.join('-')}"
    sha1 = OpenSSL::Digest::Digest.new('sha1')
    OpenSSL::HMAC.hexdigest(sha1, secret_token, string)
  end

  def verify_action(signature, action, params)
    expected = Digest::SHA1.hexdigest(sign_action(action, params))
    actual   = Digest::SHA1.hexdigest(signature)
    expected == actual
  end

  protected

    def generate_secret_token
      unless secret_token?
        self.secret_token = SecureRandom.base64(32)
      end
    end

    def record_starting_cash
      cash_activity = cash_activities.build
      cash_activity.amount = self.cash
      cash_activity.code = 'starting_balance'
      cash_activity.save
    end

    def update_subscription
      should_update = email_changed? && email?
      yield
      delay.safe_subscribe if should_update
    end

end

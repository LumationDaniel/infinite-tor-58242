# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130502023704) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
    t.integer  "site_id"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "announcements", :force => true do |t|
    t.string   "message",    :limit => 200
    t.integer  "priority",                  :default => 0
    t.datetime "retired_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "site_id"
  end

  add_index "announcements", ["site_id"], :name => "index_announcements_on_site_id"

  create_table "answers", :force => true do |t|
    t.integer  "question_id",                     :null => false
    t.string   "text",                            :null => false
    t.boolean  "right_answer", :default => false, :null => false
    t.integer  "position",                        :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "answers", ["question_id"], :name => "index_answers_on_question_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "cash_activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.string   "source_type"
    t.integer  "amount"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.integer  "game_id"
    t.integer  "question_id"
    t.string   "description"
  end

  add_index "cash_activities", ["code"], :name => "index_cash_activities_on_code"
  add_index "cash_activities", ["created_at"], :name => "index_cash_activities_on_created_at"
  add_index "cash_activities", ["game_id"], :name => "index_cash_activities_on_game_id"
  add_index "cash_activities", ["question_id"], :name => "index_cash_activities_on_question_id"
  add_index "cash_activities", ["user_id"], :name => "index_cash_activities_on_user_id"

  create_table "challenges", :force => true do |t|
    t.integer  "opponent_id"
    t.integer  "challenger_entry_id"
    t.integer  "opponent_entry_id"
    t.integer  "wager_amount"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "challenges", ["challenger_entry_id"], :name => "index_challenges_on_challenger_entry_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "display_orders", :force => true do |t|
    t.string   "scope"
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "priority"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "facebook_apprequest_recipients", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "facebook_id"
    t.integer  "facebook_apprequest_id"
    t.datetime "deleted_apprequest_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_apprequest_recipients", ["facebook_id"], :name => "index_facebook_apprequest_recipients_on_facebook_id"
  add_index "facebook_apprequest_recipients", ["user_id"], :name => "index_facebook_apprequest_recipients_on_user_id"

  create_table "facebook_apprequests", :force => true do |t|
    t.integer  "target_id"
    t.string   "target_type"
    t.integer  "user_id"
    t.string   "request_id"
    t.string   "request_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "facebook_apprequests", ["request_id"], :name => "index_facebook_apprequests_on_request_id"

  create_table "facebook_users", :force => true do |t|
    t.string   "facebook_id"
    t.string   "oauth_token"
    t.datetime "oauth_token_expires_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "link"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cash",                                       :default => 0
    t.datetime "last_facebook_sync_at"
    t.string   "email",                       :limit => 120
    t.datetime "last_access_at"
    t.integer  "local_rank",                                 :default => 0
    t.integer  "global_rank",                                :default => 0
    t.integer  "wins",                                       :default => 0
    t.integer  "loses",                                      :default => 0
    t.datetime "daily_bonus_last_awarded_on"
    t.integer  "permissions_level",                          :default => 0
    t.boolean  "likes_app_page",                             :default => false
    t.integer  "friendships_count",                          :default => 0
    t.string   "secret_token"
    t.integer  "correct_answers",                            :default => 0
    t.integer  "incorrect_answers",                          :default => 0
    t.boolean  "global_user",                                :default => false
  end

  add_index "facebook_users", ["cash"], :name => "index_facebook_users_on_cash"
  add_index "facebook_users", ["facebook_id"], :name => "index_facebook_users_on_facebook_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user_id"], :name => "index_friendships_on_user_id"

  create_table "game_groups", :force => true do |t|
    t.integer  "league_id"
    t.string   "name"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
  end

  add_index "game_groups", ["league_id"], :name => "index_game_groups_on_league_id"
  add_index "game_groups", ["permalink"], :name => "index_game_groups_on_permalink"

  create_table "games", :force => true do |t|
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.datetime "starts_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "away_score"
    t.integer  "home_score"
    t.boolean  "completed",      :default => false
    t.integer  "group_id"
    t.integer  "home_team_rank"
    t.integer  "away_team_rank"
    t.string   "tv_channel"
    t.string   "name"
    t.string   "description"
    t.datetime "live_on"
    t.integer  "cash_prize"
  end

  create_table "league_associations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leagues", :force => true do |t|
    t.string   "sport"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_association_id"
  end

  create_table "notification_preferences", :force => true do |t|
    t.integer  "user_id"
    t.integer  "notification_id"
    t.datetime "unsubscribed_on"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "notification_preferences", ["notification_id"], :name => "index_notification_preferences_on_notification_id"
  add_index "notification_preferences", ["user_id"], :name => "index_notification_preferences_on_user_id"

  create_table "notifications", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "provider_type"
    t.string   "method_name"
    t.string   "subject"
    t.string   "description"
  end

  add_index "notifications", ["provider_type", "method_name"], :name => "index_notifications_on_provider_type_and_method_name"

  create_table "pickem_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "winner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "challenges_count", :default => 0
    t.boolean  "win"
  end

  add_index "pickem_entries", ["game_id"], :name => "index_pickem_entries_on_game_id"
  add_index "pickem_entries", ["user_id"], :name => "index_pickem_entries_on_user_id"

  create_table "questions", :force => true do |t|
    t.integer  "site_id"
    t.integer  "creator_id",                              :null => false
    t.string   "text",                                    :null => false
    t.datetime "completed_on"
    t.datetime "live_on"
    t.datetime "locked_on"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "cash_prize"
    t.string   "question_type", :default => "predictive"
  end

  add_index "questions", ["completed_on"], :name => "index_questions_on_completed_on"
  add_index "questions", ["live_on"], :name => "index_questions_on_live_on"
  add_index "questions", ["site_id"], :name => "index_questions_on_site_id"

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "permalink"
    t.string   "facebook_app_id"
    t.string   "facebook_app_secret"
    t.string   "facebook_app_url"
    t.string   "facebook_app_access_token"
  end

  add_index "sites", ["permalink"], :name => "index_sites_on_permalink"

  create_table "sports", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "league_association_id"
  end

  add_index "teams", ["league_association_id"], :name => "index_teams_on_league_association_id"

  create_table "user_announcements", :force => true do |t|
    t.integer  "user_id"
    t.integer  "announcement_id"
    t.datetime "read_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_announcements", ["read_on"], :name => "index_user_announcements_on_read_on"
  add_index "user_announcements", ["user_id"], :name => "index_user_announcements_on_user_id"

  create_table "user_answers", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "win"
  end

  add_index "user_answers", ["question_id"], :name => "index_user_answers_on_question_id"
  add_index "user_answers", ["user_id"], :name => "index_user_answers_on_user_id"

  create_table "user_sites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "site_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_sites", ["site_id"], :name => "index_user_sites_on_site_id"
  add_index "user_sites", ["user_id"], :name => "index_user_sites_on_user_id"

end

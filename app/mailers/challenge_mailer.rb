require 'mandrill_mailer/base'
require 'notification_mailer'

class ChallengeMailer < MandrillMailer::Base
  include NotificationMailer
  include ActionView::Helpers::NumberHelper

  register_notification 'Incoming Challenge', :notice

  api_key ENV['MANDRILL_PASSWORD']

  default message: {
            from_email: "mailer@pickoffsports.com",
            from_name: "Pickoff Sports"
          }

  def notice(challenge)
    mail( template_name: 'Incoming Challenge',
          message: {
            to: [{
              email: challenge.opponent.email,
              name: challenge.opponent.full_name
            }],
            subject: subject_for(:notice,
                                  "%{FRIEND} sent you a challenge",
                                  FRIEND: challenge.challenger.full_name),
            global_merge_vars: [
              { name: 'UNSUB', content: unsubscribe_url_for(:notice, challenge.opponent) },
              { name: 'UPDATE_PROFILE', content: 'http://play.pickoffsports.com/profile' },
              { name: 'CURRENT_YEAR', content: Date.today.year.to_s },
              { name: 'COMPANY', content: Settings.company_name },
              { name: 'ADDRESS_HTML', content: address_html },
              { name: 'GAME_TITLE', content: challenge.game.title },
              { name: 'WAGER', content: number_to_currency(challenge.wager_amount, precision: 0) },
              { name: 'FRIEND', content: challenge.challenger.full_name },
              { name: 'FRIENDS_PICK', content: challenge.challengers_pick.name },
              { name: 'FRIEND_PIC', content: "<img src=\"https://graph.facebook.com/#{challenge.challenger.facebook_id}/picture\">" },
              { name: 'CHALLENGE_URL', content: fb_app_url("challenges/#{challenge.id}") },
              { name: 'ACCEPT_URL', content: fb_app_url("challenges/#{challenge.id}/accept") }
            ]
          },
          tags: ['Incoming Challenge']
    )
  end
end

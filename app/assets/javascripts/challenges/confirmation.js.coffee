class ChallengeConfirmation
  constructor: ->
    @el = $('#challenge-confirmation')
    @connectEvents()

  connectEvents: ->
    $('.close-button', @el).click =>
      @el.hide()
      @onSuccess()
      false

    $('.challenge-button', @el).click =>
      @el.hide()
      new Pickoff.ChallengeDialog(@game, @onSuccess).start()
      false

  populate: ->
    $('.opponent-name', @el).text(@challenge.opponent.firstName)
    $('.game .meta', @el).append($('.meta > .row', @game.el).clone())
    $('.challenger .team', @el).text(@game.chosenWinner())
    $('.opponent img').attr('src', "https://graph.facebook.com/#{@challenge.opponent.id}/picture").
                       attr('alt', @challenge.opponent.name).
                       attr('title', @challenge.opponent.name)
    $('.opponent .team', @el).text(@game.chosenLoser())
    $('.challenger .wager', @el).text("$#{@challenge.wager}")

  show: (@challenge, @game, @onSuccess) ->
    @populate()
    @el.slideInModal()

window.Pickoff.showChallengeConfirmation = (challenge, game, onSuccess) ->
  ChallengeConfirmation.instance ||= new ChallengeConfirmation()
  ChallengeConfirmation.instance.show(challenge, game, onSuccess)


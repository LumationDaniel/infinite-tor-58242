class Question
  constructor: (@el) ->
    @id = @el.attr('data-id')

  awayTeam: -> $('.away.team', @el).attr('data-name')
  homeTeam: -> $('.home.team', @el).attr('data-name')

  chosenWinner: -> $('.team.check', @el).attr('data-name')
  chosenLoser: -> $('.team:not(.check)', @el).attr('data-name')

  startsAt: -> moment(Number(@el.attr('data-starts-at')))

$ ->
  showPickConfirmation = ($question) ->
    $meta = $('.meta', $question)
    $meta.addClass('challenge-mode')

    congrats = [
      'Nice Pick!',
      'Good Job!',
      'Way to Go!',
      'Nice One!'
    ]

    congrats = congrats[Math.floor(Math.random()*1000) % congrats.length]

    unless $('.message', $meta).length
      $message = $("<div class=\"message\"><em>#{congrats}</em></div>")
      $message.css(left: -500) # hiding message to animate
      $meta.append($message)
      $message.animate(left: 0)

  # Removes the game if post-challenge prompt if on the upcoming games page.
  removeGame = ($game) ->
    if $('body#upcoming-games').length
      $game.animate(opacity: 0, height: 0, 'slow', -> $game.remove())

  skipChallenge = ($game) ->
    $('.challenge', $game).remove()
    $('.meta', $game).removeClass('challenge-mode')
    $('.meta .message', $game).remove()
    removeGame($game)
    false

  pickSoundIndex = 0
  pickSounds = [
    new buzz.sound('/sounds/slot_machine_bet_01', formats: ['mp3', 'wav']),
    new buzz.sound('/sounds/slot_machine_bet_02', formats: ['mp3', 'wav']),
    new buzz.sound('/sounds/slot_machine_bet_03', formats: ['mp3', 'wav'])
  ]

  # pick an answer
  $('.question .answer:not(.disabled):not(.check)').live 'click', ->
    $this = $(this)

    # play a sound
    pickSounds[pickSoundIndex].play()
    pickSoundIndex = (pickSoundIndex + 1) % pickSounds.length

    # check this answer, uncheck the others
    $this.addClass('check').siblings('.answer').removeClass('check')

    # animate the check
    checkWidth = 35
    checkHeight = 35
    $checkAnimation = $('#check-animation')
    checkboxOffset = $('.checkbox', $this).offset()
    checkboxOffset.left += 3
    checkboxOffset.top -= 4
    $checkAnimation.width(checkWidth).height(checkHeight).
                    show().
                    offset(checkboxOffset).
                    css(opacity:1)
    $checkAnimation.animate({
                              height: checkHeight * 2,
                              width: checkWidth * 2,
                              left: checkboxOffset.left - (checkWidth / 2),
                              top: checkboxOffset.top - (checkHeight / 2),
                              opacity: 0
                            }, 'slow', 'swing', -> $checkAnimation.hide())

    # record the pick
    $question = $this.parents('.question')
    site = $("meta[property='pickoff:site']").attr('content')
    $.post("/sites/#{site}/fb/answers/#{$question.attr('data-id')}", {
        _method: 'PUT',
        'answer_id': $this.attr('data-answer-id')
      },
      (data, status, xhr) -> showPickConfirmation($question)
    )
    false

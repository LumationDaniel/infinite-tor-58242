class Game
  constructor: (@el) ->
    @id = @el.attr('data-id')

  awayTeam: -> $('.away.team', @el).attr('data-name')
  homeTeam: -> $('.home.team', @el).attr('data-name')

  chosenWinner: -> $('.team.check', @el).attr('data-name')
  chosenLoser: -> $('.team:not(.check)', @el).attr('data-name')

  startsAt: -> moment(Number(@el.attr('data-starts-at')))

$ ->
  showChallengePrompt = ($game) ->
    $meta = $('.meta', $game)
    $meta.addClass('challenge-mode')

    congrats = [
      'Nice Pick!',
      'Good Job!',
      'Way to Go!',
      'Nice One!',
      "Awesome!",
      "Marvelous!",
      "Good show!",
      "Wonderful!",
      "Nice!",
      "Swanky!",
      "Spiffy!",
      "Right on!",
      "Not too shabby!",
      "High-five!",
      "Woo hoo!",
      "You're a MADMAN!",
      "Better challenge someone!",
      "Rockin' choice!",
      "Cheers, Mate!",
      "Bob's your uncle",
      "Can I get a witness?",
      "Fire it up!",
      "TOGA! TOGA!",
      "Who rules?",
      "Conga!",
      "Gunga, gunga-lagunga!",
      "Buehler? Anyone?",
      "Make my day.",
      "You look mahvelous",
      "Rockin' it hot!",
      "And there it is.",
      "Call me. Any time.",
      "Kickin’ it.",
      "Go ahead. Jump.",
      "Potential greatness.",
      "So solid, bro.",
      "Cyool.",
      "Tasty.",
      "Now that's strong.",
      "Sweet Candy",
      "Whoa, Nellie!",
      "Smile on that",
      "Props, sir",
      "Dorsicle!",
      "Icing on it.",
      "Nice, dude.",
      "Git on down!",
      "Hi ho the dairy O",
      "OMG - totally",
      "Champ changer",
      "Let's go Kiwi Jo!",
      "Amazing!",
      "Squirrel!!",
      "Work it!",
      "Now CHEER!",
      "Hello Cleveland!",
      "This goes to 11",
      "Fliptastic!",
      "Good on ya!",
      "Man, UR gud",
      "Raise it higher!",
      "Even higher!",
      "No Flag, man.",
      "Fro yo, Joe.",
      "Hello, Newman",
      "Hello, Jerry!",
      "Thank you, Grasshopper",
      "Nice run rate!",
      "Fries with that?",
      "Game time, baby!",
      "Sweet Lincoln's mullet.",
      "Great Odin's raven.",
      "By the beard of Zeus.",
      "Shake and bake!",
      "Now turn up the heat! ",
      "If you ain't first, you're last.",
      "Cinderella story. Outta nowhere.",
      "It's in the hole!"
    ]

    congrats = congrats[Math.floor(Math.random()*1000) % congrats.length]

    $message = $("<div class=\"message\"><em>#{congrats}</em></div>")
    $message.css(left: -500) # hiding message to animate
    $meta.append($message)

    $info = $('.info', $game)
    $challenge = $("<div class=\"challenge\"><div class=\"buttons\"><a href=\"#\" class=\"challenge-button button green medium\" title=\"Challenge a Friend\">Challenge</a></div></div>")
    $challenge.width($info.width()).height($info.outerHeight())
    $challenge.css(opacity: 0)
    $challenge.find('.challenge-button').click(-> showChallengeDialog($game))
    $buttons = $('.buttons', $challenge).css(left: 500) # hiding buttons to animate in
    $info.append($challenge)
    $challenge.animate(opacity: 1, 'fast', ->
      $message.animate(left: 10)
      $buttons.delay(100).animate(left: 230)
    )

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

  showChallengeDialog = ($game) ->
    challenge = new Pickoff.ChallengeDialog(new Game($game), -> removeGame($game))
    challenge.start()
    false

  pickSoundIndex = 0
  pickSounds = [
    new buzz.sound('/sounds/slot_machine_bet_01', formats: ['mp3', 'wav']),
    new buzz.sound('/sounds/slot_machine_bet_02', formats: ['mp3', 'wav']),
    new buzz.sound('/sounds/slot_machine_bet_03', formats: ['mp3', 'wav'])
  ]

  # Make a pick
  $('.game .team:not(.disabled):not(.check)').live 'click', ->
    $this = $(this)

    # play a sound
    pickSounds[pickSoundIndex].play()
    pickSoundIndex = (pickSoundIndex + 1) % pickSounds.length

    # check this team, uncheck the other team
    $this.addClass('check').siblings('.team').removeClass('check')

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
    $game = $this.parents('.game')
    $.post("/entries/#{$game.attr('data-id')}", {
        _method: 'PUT',
        'pickem_entry[winner_id]': $this.attr('data-team-id')
      },
      (data, status, xhr) -> showChallengePrompt($game)
    )
    false

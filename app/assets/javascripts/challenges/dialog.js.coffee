setEnabled = (btn, enabled) ->
  if enabled
    btn.removeClass('disabled')
  else
    btn.addClass('disabled')

class ChallengeDialog
  constructor: (@game, @onSuccess)->
    @stateIndex = -1
    @modal = modal = $('#challenge-modal')

    unless modal.data('modal')
      modal.modal(show:false).
      find('.modal-footer .primary.btn').click(->
        modal.data('challenge').next() unless $(this).is('.disabled')
        false
      ).end().
      find('.modal-footer .secondary.btn').click(->
        el.data('challenge').previous() unless $(this).is('.disabled')
        false
      )

    @prevButton = prevButton = modal.find('.modal-footer .secondary.btn')
    @nextButton = nextButton = modal.find('.modal-footer .primary.btn')

    getStandardMessage = =>
      wager = modal.find('#challenge_wager_amount').val()
      "I bet you $#{wager} in Pickoff Cash that #{@game.chosenWinner()} will beat #{@game.chosenLoser()} on #{@game.startsAt().format('dddd, MMMM DD')}."

    @states = [
      {
        name: 'select-friend'

        enter: ->
          # configure the friends selector
          this.view.append('<div id="jfmfs-container"></div>')
          $('#jfmfs-container').
            jfmfs(max_selected: 1, friend_fields: 'id,name,first_name').
            bind("jfmfs.selection.changed", (e, selection) ->
              setEnabled(nextButton, selection.length > 0)
            )
          setEnabled(nextButton, false)

        reset: ->
          # create/re-create the jfmfs control
          $('#jfmfs-container').remove()
      },
      {
        name: 'wager'

        enter: ->
          selectedFriends = $('#jfmfs-container').data('jfmfs').getSelectedIdsAndData()

          this.view.find('form').hide()

          view = this.view
          $.get("/fb/challenges/#{@game.id}.json", opponent_fb_id: selectedFriends[0].id).
          success((data, textStatus, xhr) ->
            maxWager = Math.min(data.opponent_accessible_cash, data.accessible_cash)

            hint = ["Max wager: #{maxWager}"]
            if data.accessible_cash > data.opponent_accessible_cash
              hint.push "(this is the most #{selectedFriends[0].name} can wager)"
            else
              hint.push "(this is your available Pickoff cash minus current challenges)"

            view.find('.max-hint').text(hint.join(' ')).end().
                 find('form').show()

            amount = modal.find('#challenge_wager_amount')#.spinner(min: 1, max: maxWager, step: 100)
            amount.attr('step', '100')
            amount.attr('min', '1')
            amount.attr('max', String(maxWager))
          )

          this.view.find('.max-hint').text('').end().
                    find('.opponent').text(selectedFriends[0].name)

        reset: ->
          modal.find('#challenge_wager_amount').val('500')
      },
      {
        name: 'apprequest'

        enter: ->
          selectedFriends = $('#jfmfs-container').data('jfmfs').getSelectedIdsAndData()
          standardMessage = getStandardMessage()

          this.view.find('.message').text(standardMessage).end().
                    find('.challenge-message-container').append('<textarea id="challenge-message"></textarea>').end().
                    find('.opponent').text(selectedFriends[0].name)

          messageMaxLen = 254 - standardMessage.length

          requireLength = -> setEnabled(nextButton, $(this).val().length <= messageMaxLen)

          $('#challenge-message').
              val("Want to accept the challenge? Join me for a friendly game of sports pick 'em!").
              change(requireLength).keyup(requireLength).
              charCount(allowed: messageMaxLen, css: 'counter help-block', counterText: 'characters left: ')

        reset: ->
          this.view.find('.challenge-message-container').children().remove()
      },
      {
        name: 'finish'

        enter: ->
          setEnabled(prevButton, false)

          message = [getStandardMessage(), modal.find('#challenge-message').val()].join(' ')
          opponent  = $('#jfmfs-container').data('jfmfs').getSelectedIdsAndData()[0]
          @challenge.submitChallenge(opponent, message)
      }
    ]

  submitChallenge: (opponent, message) ->
    showChallengeConfirmation = =>
      Pickoff.showChallengeConfirmation({
        opponent: opponent,
        wager: $('#challenge_wager_amount', @modal).val()
      }, @game, @onSuccess)

    FB.ui({
        method : 'apprequests'
        message: message
        to     : opponent.id
      },
      (response) =>
        if response and response.request?
          $.post("/fb/challenges/#{@game.id}.json",
            _method       : 'PUT',
            request_id    : response.request,
            wager_amount  : $('#challenge_wager_amount', @modal).val(),
            opponent_fb_id: opponent.id,
            opponent_name : opponent.name
          ).success((data, textStatus, xhr) =>
            $('.challenges-count').text(data.total_challenges)
            #$(".game[data-id=#{@game.id}]").
            #    find('input.pick-winner').attr('disabled', '').end()
          )
          showChallengeConfirmation()
        @modal.modal('hide')
    )

  start: ->
    @modal.data('challenge', this)
    @modal.find('.step').hide()

    # setup the challenge states
    modal = @modal
    setup = (state) ->
      state.view = modal.find(".step.#{state.name}")
      state.reset() if state.reset?
    for state in @states
      state.challenge = this
      state.game = @game
      setup(state)

    # enter the first state
    this.enterState(0)

    @modal.modal('show')

    targetOffsetTop = $("li[data-id=#{@game.id}]").offset().top
    layoutAbove = targetOffsetTop + @modal.height() > $(document.body).height()

    modalTop = if layoutAbove then targetOffsetTop - @modal.height() else targetOffsetTop
    @modal.css('top', modalTop + 250) # modals have a negative margin

    FB.Canvas.scrollTo(0, modalTop - 100)
    # Animating the scrolling doesn't work really well
    # FB.Canvas.getPageInfo((pageInfo) ->
    #   $(y: pageInfo.scrollTop).animate({ y: modalTop - 100 }, {
    #     duration: 1000,
    #     step: (offset) ->
    #       FB.Canvas.scrollTo(0, offset)
    #   })
    # )

  enterState: (index) ->
    if @stateIndex >= 0 and @states[@stateIndex].view?
      @states[@stateIndex].view.hide()

    @stateIndex = index

    setEnabled(@prevButton, @stateIndex > 0)
    setEnabled(@nextButton, @stateIndex + 1 < @states.length)

    state = @states[index]
    state.enter()
    state.view.show()

  next: ->
    if @stateIndex + 1 < @states.length
      this.enterState(@stateIndex + 1)

  previous: ->
    if @stateIndex > 0
      @states[@stateIndex].reset() if @states[@stateIndex].reset?
      this.enterState(@stateIndex - 1)

window.Pickoff.ChallengeDialog = ChallengeDialog



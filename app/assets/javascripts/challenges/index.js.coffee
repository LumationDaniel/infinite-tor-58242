$ ->
  # accept/decline challenges
  $('li.challenge').
    find('.accept.btn').click(->
      $challenge = $(this).parents('li.challenge')
      challengeId = $challenge.attr('data-id')

      $.post("/fb/challenges/#{challengeId}/accept.json").
      success((data, status, xhr) ->
        $('.challenges-count').text(data.total_challenges)
      )

      $challenge.remove()
      false
    ).end().
    find('.decline.btn').click(->
      $challenge = $(this).parents('li.challenge')
      challengeId = $challenge.attr('data-id')

      $.post("/fb/challenges/#{challengeId}/decline.json")

      $challenge.remove()
      false
    )


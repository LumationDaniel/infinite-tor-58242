$ ->
  $miniLeaderboard = $('#mini-leaderboard')
  if $miniLeaderboard.length
    rowHeight = 57
    $('.up-button', $miniLeaderboard).click ->
      $viewport = $(this).siblings('.player-carousel-content')
      scrollTop = $viewport.scrollTop()
      $viewport.animate(scrollTop: scrollTop - (rowHeight * 5))
    
    $('.down-button', $miniLeaderboard).click ->
      $viewport = $(this).siblings('.player-carousel-content')
      scrollTop = $viewport.scrollTop()
      $viewport.animate(scrollTop: scrollTop + (rowHeight * 5))

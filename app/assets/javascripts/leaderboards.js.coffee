$ ->
  if $('#leaderboard').length
    $('select[name=time]').change -> $('#filter-form').submit()

    $('#filter-form .people-filter .btn').click ->
      $('#filter-form input[name=sort]').val('earnings')
      $('#filter-form input[name=people]').val($(this).attr('data-value'))
      $('#filter-form').submit()

    $('th a.sort').click ->
      sortBy = $(this).attr('data-sort-by')
      $('#filter-form input[name=sort]').val(sortBy)
      sortDirection = $(this).attr('data-sort-direction')
      $('#filter-form input[name=sort_direction]').val(sortDirection)
      $('#filter-form').submit()

    $('th a.sort[data-sort-by=accuracy]').popover()
    $('th a.sort[data-sort-by=picks]').popover()
    $('th a.sort[data-sort-by=friends]').popover()
    $('td.accuracy span.insufficient-picks').popover()

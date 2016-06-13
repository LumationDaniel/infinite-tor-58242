$ ->
  $('select#game_group_id').change ->
    groupId = $(this).val()
    page = 1
    options = '<option value></option>'
    receivedTeams = (data, status, xhr) ->
      options += $.map(data, (element, index) ->
        "<option value=\"#{element.id}\">#{element.name}</option>"
      ).join('')

      if data.length == 0 || data.length < 30
        $('select#game_home_team_id, select#game_away_team_id').html(options)
      else
        page += 1
        $.get "/admin/teams.json?q[league_association_leagues_game_groups_id_eq]=#{groupId}&order=name_asc&page=#{page}", receivedTeams
    $.get "/admin/teams.json?q[league_association_leagues_game_groups_id_eq]=#{groupId}&order=name_asc&page=#{page}", receivedTeams
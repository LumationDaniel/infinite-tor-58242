$ ->
  $('body.admin_display_orders.new select#display_order_scope, body.admin_display_orders.edit select#display_order_scope').change ->
    if $(this).val() == 'leaderboard'
      page = 1
      options = '<option value></option>'

      getGameGroups = ->
        $.get "/admin/game_groups.json?order=name_asc&page=#{page}", receivedGameGroups

      receivedGameGroups = (data, status, xhr) ->
        options += $.map(data, (element, index) ->
          "<option value=\"#{element.id}\">#{element.label}</option>"
        ).join('')

        if data.length == 0 || data.length < 30
          $('select#display_order_target_id').html(options)
          $('input#display_order_target_type').val('GameGroup')
        else
          page += 1
          getGameGroups()

      getGameGroups()

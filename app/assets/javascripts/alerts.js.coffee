# Handle the various types of application alerts
$ ->
  $('.alerts .close').live('click', ->
    alertBox = $(this).parents('.alert-message')

    # Mark announcements as read
    if alertBox.attr('data-announcement-id')
      $.ajax "/alerts/announcement:#{alertBox.attr('data-announcement-id')}",
        type: 'POST'
        data:
          _method: 'DELETE'

    alertBox.remove()
    false
  )

deleteSessionNotice = (key) ->
  $.ajax "/alerts/session_notice:#{key}",
    type: 'POST'
    data:
      _method: 'DELETE'

createDailyNoticeShown = (key, left) ->
  (notice) ->
    button = $(document.createElement('a'))
    button.text('Collect Bonus!')
    successSound = new buzz.sound('/sounds/coin_magic_07', formats: ['mp3', 'wav'])
    buttonClick = ->
      _gaq.push(['_trackEvent', key, 'Close']);
      button.unbind('click', buttonClick)
      successSound.play()
      setTimeout((-> window.Pickoff.hideNotice()), 500) # delay so the sound effect plays along side closing
      deleteSessionNotice(key)

    button.click(buttonClick)
    notice.append(button)

window.Pickoff.addNotice = (key) ->
  @notices ||= []
  @notices.push(key)
  $(=> @showNotice())

window.Pickoff.showNotice = (delay = true)->
  if @notices and @notices.length > 0
    nextNotice = @notices.shift()
    notice = $('#notice')
    notice.removeClass()
    notice.addClass(nextNotice)

    modalShown = =>
      if @noticeTypes[nextNotice].shown?
        @noticeTypes[nextNotice].shown(notice)
      _gaq.push(['_trackEvent', nextNotice, 'Show']);

    if delay
      setTimeout((-> notice.slideInModal(onShown: modalShown)), 1000)
    else
      notice.slideInModal(onShown: modalShown)

window.Pickoff.hideNotice = ->
  $('#notice').hide().html('')
  @showNotice(false)

window.Pickoff.noticeTypes =
  daily_bonus:
    shown: createDailyNoticeShown('daily_bonus')
  daily_bonus_with_like_bonus:
    shown: createDailyNoticeShown('daily_bonus_with_like_bonus')

  daily_bonus_50:
    shown: createDailyNoticeShown('daily_bonus_50')
  daily_bonus_50_with_like_bonus:
    shown: createDailyNoticeShown('daily_bonus_50_with_like_bonus')

  daily_bonus_100:
    shown: createDailyNoticeShown('daily_bonus_100')
  daily_bonus_100_with_like_bonus:
    shown: createDailyNoticeShown('daily_bonus_100_with_like_bonus')

  daily_bonus_200:
    shown: createDailyNoticeShown('daily_bonus_200')
  daily_bonus_200_with_like_bonus:
    shown: createDailyNoticeShown('daily_bonus_200_with_like_bonus')

  daily_bonus_500:
    shown: createDailyNoticeShown('daily_bonus_500')
  daily_bonus_500_with_like_bonus:
    shown: createDailyNoticeShown('daily_bonus_500_with_like_bonus')


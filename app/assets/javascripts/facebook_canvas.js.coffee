# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('a.invite-friends').click ->
    FB.ui
      method : 'apprequests',
      message: 'Come join me and play a friendly game of sports pickem!'
    false

  $('a.post-feed').click ->
    FB.ui
      method: 'feed',
      link: 'http://apps.facebook.com/pickoffgame',
      name: $(this).attr('data-name'),
      description: $(this).attr('data-description')
    false

  $('.sub-header .select').click ->
    $(this).siblings('.select-list').toggleClass('shown')

  if FB?
    FB.Canvas.setAutoGrow()
    FB.getLoginStatus()

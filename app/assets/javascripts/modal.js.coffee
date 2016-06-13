$.fn['slideInModal'] = (options = {}) ->
  return @each ->
    $this = $(this)
    FB.Canvas.getPageInfo (info) ->
      t = ((info.clientHeight - $this.height()) / 2) + info.scrollTop
      l = $(document).width()
      $this.css(top: t, left: l, display: 'block', position: 'absolute')
      $this.animate {left: (l - $this.width()) / 2}, 'fast', ->
        options.onShown.apply($this) if options.onShown?

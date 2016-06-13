$ ->
  $('textarea.limited, input.limited').each (i,el) ->
    $el = $(el)
    $el.maxlength('feedback': $el.siblings('.inline-hints').find('.chars-left'))

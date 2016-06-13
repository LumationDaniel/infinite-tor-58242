$ ->
  if $('.new.admin_questions').length
    $f = $('form.formtastic.question')

    adjustFormToQuestionType = ->
      questionType = $("[name='question[question_type]']", $f).val()

      if questionType == 'predictive'
        for cb in $("input[type=checkbox]", $f)
          $cb = $(cb)
          if $cb.attr('name').match(/\[right_answer\]$/)
            $cb.parents('label').hide()
      else # trivia
        for cb in $("input[type=checkbox]", $f)
          $cb = $(cb)
          if $cb.attr('name').match(/\[right_answer\]$/)
            $cb.parents('label').show()

    adjustFormToQuestionType()

    if $f.is("#new_question")
      $("[name='question[question_type]']", $f).change(adjustFormToQuestionType)

backspace = 8
tab = 9
enter = 13
end = 35
down_arrow = 40
delete_key = 46
zero_key = 48
numpad_decimal_point = 110
decimal_point = 190
nine_key = 57
numpad_zero = 96
numpad_nine = 105

jQuery.fn.ForceNumericOnly = ->
  @each ->
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      e.ctrlKey or
        key == backspace or
        key == tab or
        key == enter or
        key == delete_key or
        key == decimal_point or
        key == numpad_decimal_point or
        key >= end and key <= down_arrow or
        key >= zero_key and key <= nine_key or
        key >= numpad_zero and key <= numpad_nine

    $(this).on 'input paste', (e) ->
      $input = $(e.target)
      oldText = $input.val()
      setTimeout(
        =>
          text = $input.val()
          unless text.match(/^[0-9\.\-]+$/)
            $input.val(oldText)
            $input.trigger('change')
        0
      )

jQuery.fn.currencyInput = ->
  @each ->
    $(@).keyfilter(/[\d\.\s\$,]/)

jQuery.fn.NumberLimiter =(maxValue) ->
  @each ->
    $(this).on 'input', (e) ->
      if ( $(this).val() > maxValue )
        $(this).val(maxValue)
        $(this).trigger('change')

jQuery.fn.phoneNumber = ->
  @each ->
    $(this).mask('000 000 0000');

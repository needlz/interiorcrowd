backspace = 8
tab = 9
enter = 13
end = 35
down_arrow = 40
delete_key = 46
zero_key = 48
decimal_point = 110
nine_key = 57
numpad_zero = 96
numpad_nine = 105

jQuery.fn.ForceNumericOnly = ->
  @each ->
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      key == backspace or
        key == tab or
        key == enter or
        key == delete_key or
        key == decimal_point or
        key >= end and key <= down_arrow or
        key >= zero_key and key <= nine_key or
        key >= numpad_zero and key <= numpad_nine

    $(this).on 'input paste', (e) ->
      oldText = $(e.target).val()
      setTimeout ->
        text = $(e.target).val()
        $(e.target).val(oldText) unless text.match(/^[0-9]+$/)
      0

jQuery.fn.NumberLimiter =(maxValue) ->
  @each ->
    $(this).on 'input', (e) ->
      if ( $(this).val() > maxValue )
        $(this).val(maxValue)

jQuery.fn.phoneNumber = ->
  @each ->
    $(this).mask('000 000 0000');

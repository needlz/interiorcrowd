jQuery.fn.ForceNumericOnly = ->
  @each ->
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      # allow backspace, tab, delete, enter, arrows, numbers and keypad numbers ONLY
      # home, end, period, and numpad decimal
      key == 8 or key == 9 or key == 13 or key == 46 or key == 110 or key >= 35 and key <= 40 or key >= 48 and key <= 57 or key >= 96 and key <= 105
    return
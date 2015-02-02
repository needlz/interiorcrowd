jQuery.fn.ForceNumericOnly = ->
  @each ->
    $(this).keydown (e) ->
      key = e.charCode or e.keyCode or 0
      key == 8 or key == 9 or key == 13 or key == 46 or key == 110 or key >= 35 and key <= 40 or key >= 48 and key <= 57 or key >= 96 and key <= 105

    $(this).on 'input paste', (e) ->
      oldText = $(e.target).val()
      setTimeout ->
        text = $(e.target).val()
        $(e.target).val(oldText) unless text.match(/^[0-9]+$/)
      0
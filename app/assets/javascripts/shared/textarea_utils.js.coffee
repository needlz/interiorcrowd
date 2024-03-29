window.emailRegex = /^([A-Za-z0-9_\-\.\+])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/

window.trimedVal = ($input)->
  $.trim($input.val())

$.fn.selectRange = (start, end) ->
  if !end
    end = start
  @each ->
    if @setSelectionRange
      @focus()
      @setSelectionRange(start, end)
    else if @createTextRange
      range = @createTextRange()
      range.collapse(true)
      range.moveEnd('character', end)
      range.moveStart('character', start)
      range.select()

$.fn.emulatePlaceholder = (placeholder) ->
  @val(placeholder) if @val() == ''
  @mousedown (event) =>
    if @val() == placeholder
      event.preventDefault()
      @selectRange(0)
  @keydown =>
    if @val() == placeholder
      @val('')
  @blur =>
    if @val() == ''
      @val(placeholder)

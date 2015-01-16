class @ValidationMessages

  constructor: (@validations)->

  reset: ->
    @valid = true
    @validationMessage = null
    @$elementToFocus = null

  addMessage: ($validationMessage, text, $elementToFocus)->
    @valid = false
    $validationMessage.text(text)
    @$elementToFocus = @$elementToFocus || $elementToFocus

  focusOnMessage: ->
    if @$elementToFocus
      @$elementToFocus.get(0).scrollIntoView()
      @$elementToFocus.focus()

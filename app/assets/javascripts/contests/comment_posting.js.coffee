class @CommentPosting

  constructor: (textarea, hint)->
    @hint = hint
    @textarea = textarea

  hideHint: ->
    $(@hint).css 'visibility', 'hidden'

  showHint: ->
    $(@hint).css('visibility', 'visible');

  clearTextArea: ->
    $(@textarea).val('')

  clearHintTimeout: ->
    if hintTimer
      clearTimeout hintTimer
      hintTimer = null

  setHintTimeout: =>
    hintTimer = setTimeout(=>
      @.hideHint()
    , 3000)
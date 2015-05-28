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

$ ->
  #$('.new_reviewer_feedback').on 'ajax:success', ->
  #  mixpanel.track('Contest commented by a reviewer', { contest_id: $('.contest').data('id') })
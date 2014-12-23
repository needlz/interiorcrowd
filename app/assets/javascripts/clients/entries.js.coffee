class @Answers
  init: ->
    @bindAnswerButtons()
    @bindWinnerButton()
    @bindWinnerDialogButtons()

  bindWinnerButton: ->
    $('.winner-answer').popover({
      html: true
      placement: 'auto'
      title: I18n.winner_dialog.title
      content: ->
        requestId = $(@).parents('.moodboard').attr('data-id')
        $('.winner-dialog-template .winner-dialog').clone().attr('data-id', requestId)
    })

  bindWinnerDialogButtons: ->
    self = @
    $('body').on('click', '.winner-dialog .no-button', ->
      self.hidePopover($(@))
    ).on('click', '.winner-dialog .yes-button', ->
      self.onDialogYesClick(@)
    )

  bindAnswerButtons: ->
    self = @
    $('.answers').find('.answer-no, .answer-maybe, .answer-favorite').click ->
      requestId = $(@).parents('.moodboard').attr('data-id')
      answer = $(@).attr('answer')
      self.sendAnswer(requestId, answer)

  sendAnswer: (requestId, answer, custom_callbacks)->
    callbacks = @bindViewUpdate(requestId, answer, custom_callbacks)
    options = $.extend(
      {
        type: 'POST',
        url: @requestAnswerPath(requestId)
        data: { answer: answer }
      },
      callbacks)
    $.ajax(options)

  requestAnswerPath: (requestId)->
    $(".moodboard[data-id='#{ requestId }'] .answers").attr('data-url')

  bindViewUpdate: (requestId, answer, callbacks)->
    onUpdate = $.extend({}, callbacks)
    onUpdateSuccess = onUpdate.success if onUpdate.success
    onUpdate.success = (data)=>
      @updateView(requestId, answer) if data.answered
      onUpdateSuccess?(data)
    onUpdate

  updateView: (requestId, answer)->
    $(".moodboard[data-id='#{ requestId }'] .current-answer").text(answer)

  hidePopover: ($popover_element)->
    id = $popover_element.parents('.winner-dialog').attr('data-id')
    $(".moodboard[data-id='#{id}'] .winner-answer").popover('hide')

  onDialogYesClick: (button)->
    self = @
    $button = $(button)
    $dialog = $button.parents('.winner-dialog')
    requestId = $dialog.attr('data-id')
    $dialog.find(':button').prop('disabled', true)
    self.sendAnswer(requestId, 'winner', {
      success: (data)->
        self.hidePopover($button)
      error: ->
        self.hidePopover($button)
    })

$('document').ready ->
  answers = new Answers()
  answers.init()

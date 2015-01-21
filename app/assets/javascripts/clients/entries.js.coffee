class @Answers
  init: ->
    @bindAnswerButtons()
    @bindWinnerButton()
    @bindWinnerDialogButtons()

  bindWinnerButton: ->
    $('.winner-answer').click (event)=>
      requestId = $(event.target).parents('.moodboard').data('id')
      $('#pickWinnerModal').data('id', requestId)
      $('#pickWinnerModal').modal('show');

  bindWinnerDialogButtons: ->
    self = @
    $('#pickWinnerModal').on('click', '.winner-dialog .no-button', (event)->
      event.preventDefault()
      self.hidePopover($(@))
    ).on('click', '.winner-dialog .yes-button', (event)->
      event.preventDefault()
      self.onDialogYesClick(@)
    )

  bindAnswerButtons: ->
    self = @
    $('.answers').find('.answer-no, .answer-maybe, .answer-favorite').click ->
      requestId = $(@).parents('.moodboard').data('id')
      answer = $(@).data('answer')
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
    onUpdate.success = (response)=>
      answerSaved = response.answered
      @updateView(requestId, answer) if answerSaved
      onUpdateSuccess?(response)
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

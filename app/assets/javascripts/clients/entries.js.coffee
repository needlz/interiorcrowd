class @Answers
  init: ->
    @bindAnswerButtons()
    @bindWinnerButton()
    @bindWinnerDialogButtons()

  bindWinnerButton: ->
    $('.winner-answer').each ->
      $element = $(@)
      $element.popover({
        html: true
        placement: 'auto'
        title: I18n.winner_dialog.title
        content: """
            <div class="col-xs-12 winner-dialog" data_id="#{ $element.parents('.moodboard').attr('data_id') }">
              <div>#{ I18n.winner_dialog.text }</div>
              <button type="button" class="no-button col-xs-5 btn btn-default">#{ I18n.winner_dialog.no }</button>
              <button type="button" class="yes-button col-xs-5 pull-right btn btn-primary" data-style="expand-up">#{ I18n.winner_dialog.yes }</button>
            </div>
          """
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
      requestId = $(@).parents('.moodboard').attr('data_id')
      answer = $(@).attr('answer')
      self.sendAnswer(requestId, answer)

  sendAnswer: (requestId, answer, callbacks)->
    options = $.extend(
      {
        type: 'POST',
        url: "/contest_requests/#{requestId}/answer" # TODO
        data: { answer: answer }
      },
      callbacks)
    $.ajax(options)

  hidePopover: ($popover_element)->
    id = $popover_element.parents('.winner-dialog').attr('data_id')
    $(".moodboard[data_id='#{id}'] .winner-answer").popover('hide')

  onDialogYesClick: (button)->
    $button = $(button)
    $dialog = $button.parents('.winner-dialog')
    requestId = $dialog.attr('data_id')
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

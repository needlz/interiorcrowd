bindWinnerButton = ->
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

bindWinnerDialogButtons = ->
  $('body').on('click', '.winner-dialog .no-button', ->
    $('.winner-answer').popover('hide')
  ).on('click', '.winner-dialog .yes-button', ->
    $button = $(@)
    $dialog = $button.parents('.winner-dialog')
    requestId = $dialog.attr('data_id')
    $dialog.find(':button').prop('disabled', true)
    $.ajax({
      type: 'POST',
      url: "/contest_requests/#{requestId}/answer" # TODO
      data: { answer: 'winner'  }
      success: (data)->
        $('.winner-answer').popover('hide')
      error: ->
        $('.winner-answer').popover('hide')
    })
  )

bindAnswerButtons = ->
  $('.answers').find('.answer-no, .answer-maybe, .answer-favorite').click ->
    requestId = $(@).parents('.moodboard').attr('data_id')
    $.ajax({
      type: 'POST',
      url: "/contest_requests/#{requestId}/answer" # TODO
      data: { answer: $(@).attr('answer')  }
    })

$('document').ready ->
  bindAnswerButtons()
  bindWinnerButton()
  bindWinnerDialogButtons()

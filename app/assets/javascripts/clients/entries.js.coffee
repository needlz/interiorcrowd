class EntriesPage

  @init: ->
    answers = new Answers()
    answers.init()

    PopulatedInputs.init()
    ScrollBars.style()
    DesignerInvitations.bindInviteButtons()
    ContestNotes.bindAjaxSuccess()
    ResponsesFilter.init()

class ScrollBars

  @style: ->
    $('#scrollbox4').enscroll({
      verticalTrackClass: 'track4',
      verticalHandleClass: 'handle4',
      minScrollbarLength: 28
    });

class DesignerInvitations

  @buttonSelector: '.invite-designer'

  @bindInviteButtons: ->
    $('.profile-card').find(@buttonSelector).click (event)=>
      $button = $(event.target)
      designerId = $button.parents('.profile-card').data('id')
      @sendInviteRequest(designerId, $button)

  @getContestId: ->
    $('input.contest').data('id')

  @sendInviteRequest: (designerId, $button) ->
    $button.text(I18n.invitations.sending_invitation)
    $.ajax(
      data: { designer_id: designerId, contest_id: @getContestId() }
      url: '/designer_invitations'
      type: 'POST'
      success: (response)=>
        $button.closest('button').find('b').text(I18n.invitations.invited).removeClass(@buttonSelector)
    )

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
    $('#pickWinnerModal').on('click', '.no-button', (event)->
      event.preventDefault()
      self.hidePopover($(@))
    ).on('click', '.yes-button', (event)->
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
    "/contest_requests/#{ requestId }/answer"

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
    $('#pickWinnerModal').modal('hide');

  onDialogYesClick: (button)->
    self = @
    $button = $(button)
    $dialog = $button.parents('#pickWinnerModal')
    requestId = $dialog.data('id')
    $dialog.find(':button').prop('disabled', true)
    self.sendAnswer(requestId, 'winner', {
      success: (data)->
        self.hidePopover($button)
      error: ->
        self.hidePopover($button)
    })

class ContestNotes

  @bindAjaxSuccess: ->
    $('body').on 'ajax:success', '#new_contest_note', (event, data, status, xhr)=>
      @refreshNotes(data)

  @refreshNotes: (notes) ->
    $notesList = $('.client-notes-list ul')
    $notesList.find('> :not(.template)').remove()
    $template = $notesList.find('.template')
    $.each notes, (index, note)=>
      @prependNote($notesList, $template, note)

  @prependNote: ($notesList, $template, note)->
    $note = $template.clone()
    $timeAgo = $note.find('.time-ago')
    $timeAgo.text(note.created_at)
    $note.find('.note-text').html(note.text)
    $note.find('.note-text').append($timeAgo)
    $notesList.append($note.html())

class ResponsesFilter

  @init: ->
    @bindDropdown()
    @styleDropdown()

  @bindDropdown: ->
    $('.sortBySelect').change (event)->
      answer = $(event.target).val()
      $form = $('#responses-filter-form')
      $form.find('[name="answer"]').val(answer)
      $form.submit()

  @styleDropdown: ->
    $(".selectpicker").selectpicker
      style: "btn-selector-medium font15"
      header: I18n.filter_by

$ ->
  EntriesPage.init()

class EntriesPage

  @init: ->
    answers = new Answers()
    answers.init()

    ScrollBars.style()
    contestId = @getContestId()
    DesignerInvitations.bindInviteButtons(contestId)
    ContestNotes.bindAjaxSuccess()
    ResponsesFilter.init()
    ReviewerInvitations.init(contestId)

  @getContestId: ->
    $('input.contest').data('id')

class ScrollBars

  @style: ->
    $('#scrollbox4').enscroll({
      verticalTrackClass: 'track4',
      verticalHandleClass: 'handle4',
      minScrollbarLength: 28
    });

class DesignerInvitations

  @buttonSelector: '.invite-designer'

  @bindInviteButtons: (contestId)->
    $('.profile-card').find(@buttonSelector).click (event)=>
      $button = $(event.target)
      designerId = $button.parents('.profile-card').data('id')
      @sendInviteRequest(designerId, $button, contestId)

  @sendInviteRequest: (designerId, $button, contestId) ->
    $button.text(I18n.invitations.sending_invitation)
    $.ajax(
      data: { designer_id: designerId, contest_id: contestId }
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
    $('.sortBySelect').change (event)=>
      answer = $(event.target).val()
      @sendFilterForm(answer)

  @sendFilterForm: (answer)->
    $form = $('#responses-filter-form')
    $form.find('[name="answer"]').val(answer)
    $form.submit()

  @styleDropdown: ->
    $(".selectpicker").selectpicker
      style: "btn-selector-medium font15"
      header: I18n.filter_by

class InvitationInputs extends PopulatedInputs

  @container: '.reviewer-invitations .invitations-inputs'

  @generateNewLink: ->
    $row = $('.reviewer-invitations .template .lnk_container').first()
    $formclone = $row.clone()
    $formclone.find('input').val ''
    $formclone

class ReviewerInvitations

  @init: (contestId)->
    @contestId = contestId
    InvitationInputs.init()
    @bindInviteButtons()

  @bindInviteButtons: ->
    $('.reviewer-invitations').on 'click', '.perform-invite', (event)=>
      $button = $(event.target)
      @inviteButtonClick($button)

  @inviteButtonClick: ($button)->
    $invitationRow = $button.parents('.invitation-row')
    username = $invitationRow.find('.nameInvite').val()
    email = $invitationRow.find('.emailInvite').val()
    if @inputValid(username, email)
      $button.text(I18n.reviewer_invitations.sending)
      @sendInvite($button, username, email)

  @inputValid: (username, email)->
    username.length && email.length && /@/.test(email)

  @sendInvite: ($button, username, email)->
    $.ajax(
      data: { reviewer_invitation: { username: username, email: email }, contest_id: @contestId }
      url: '/reviewer_invitations'
      type: 'POST'
      success: (response)=>
        @inviteOnSuccess($button, response)
      error: ->
        $button.text('Invite (error occured during last try)')
    )

  @invitedRows: ->
    $(InvitationInputs.container).find('.invitation-row:not(.lnk_container)')

  @invitableRows: ->
    $(InvitationInputs.container).find('.invitation-row.lnk_container')

  @inviteOnSuccess: ($button, response)->
    $row = $button.closest('.invitation-row')
    @updateRow($row, response)
    @moveToTop($row)
    if @invitableRows().length
      InvitationInputs.populateExamplesInputs()
    else
      InvitationInputs.addLink()

  @updateRow: ($row, response)->
    $row.removeClass('lnk_container')
    $row.find('.buttons').empty()
    $row.find('input').each ->
      $('<span>', { text: @.value }).insertAfter(@)
      $(@).remove()
    $link = $('<a>')
    $link.attr('href', response.url)
    $link.text(response.token)
    $label = $('<label>').text(I18n.reviewer_invitations.feedback_link)
    $row.find('.buttons').append($label, $link)

  @moveToTop: ($row)->
    if @invitedRows.length
      $row.detach().insertAfter(@invitedRows.last())
    else
      $row.detach().prependTo($(InvitationInputs.container))
$ ->
  EntriesPage.init()

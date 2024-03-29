class EntriesPage

  @init: ->
    answers = new Answers()
    answers.init()

    ScrollBars.style()
    contestId = @getContestId()
    DesignerInvitationButton.bindInviteButtons(contestId)
    ContestNotes.init()
    ResponsesFilter.init()
    ReviewerInvitations.init(contestId)

  @getContestId: ->
    $('input.contest').data('id')

class @DesignerBlocks

  @fitHeight: ->
    $('.designerBox .avatar').each (index, element)->
      $element = $(element)
      $element.css('height', $element.get(0).offsetWidth)

    @setupEllipsis()

    maxProfileCardHeight = null
    oneInRow = window.matchMedia('(max-width: 768px)').matches

    $('.designers-row').each (i, row)=>
      maxProfileCardHeight = 0
      $rowCards = $(row).find('.profile-card')
      $rowCards.css 'height', ''
      if !oneInRow
        $rowCards.each ->
          maxProfileCardHeight = $(@).height() if maxProfileCardHeight < $(@).height()
        $rowCards.css 'height', "#{ maxProfileCardHeight }px"

  @setupEllipsis: ->
    $('.designerBox .designerDesc').dotdotdot({ height: 50 });

class ScrollBars

  @style: ->
    $('#scrollbox4').customScrollBar()

class @Answers

  requestIdContainerSelector: '.moodboard, .designConcept'

  init: ->
    @bindAnswerButtons()
    @bindWinnerButton()
    @bindWinnerDialogButtons()

  bindWinnerButton: ->
    $('.answer-winner').click (event)=>
      requestId = $(event.target).parents(@requestIdContainerSelector).data('id')
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
    $('.answers').find('.answer-no, .answer-maybe, .answer-favorite').click (e)=>
      requestId = $(e.target).parents(@requestIdContainerSelector).data('id')
      answer = $(e.target).data('answer')
      self.sendAnswer(requestId, answer)

  onDialogYesClick: (button)->
    self = @
    $button = $(button)
    $dialog = $button.parents('#pickWinnerModal')
    requestId = $dialog.data('id')
    $dialog.find(':button').prop('disabled', true)
    self.sendAnswer(requestId, 'winner', {
      success: (data)->
        self.hidePopover($button)
        window.location.href = '/client_center/entries';
      error: ->
        self.hidePopover($button)
    })

  sendAnswer: (requestId, answer, custom_callbacks)->
    callbacks = @bindViewUpdate(requestId, answer, custom_callbacks)
    options = $.extend(
      {
        type: 'POST',
        url: @requestAnswerPath(requestId)
        data: { answer: answer }
      },
      callbacks)
    mixpanel.track('Answer to concept board', { answer: answer, concept_board_id: requestId })
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

  updateView: (requestId, answer)=>
    $board = $(@requestIdContainerSelector).filter("[data-id=#{requestId}]")
    $board.find("[data-answer]").removeClass('result-answer')
    $board.find(" [data-answer=#{answer}]").addClass('result-answer')

  hidePopover: ($popover_element)->
    $('#pickWinnerModal').modal('hide');

class ContestNotes

  @init: ->
    @bindAjaxSuccess()
    @bindClearingOfTextarea()

  @bindAjaxSuccess: ->
    $('body').on 'ajax:success', '#new_contest_note', (event, data, status, xhr)=>
      mixpanel.track 'Contest note sent', { contest_id: EntriesPage.getContestId() }
      @refreshNotes(data)

  @bindClearingOfTextarea: ->
    $('body').on 'ajax:send', '#new_contest_note', (event, data, status, xhr)=>
      $('#contest_note_text').val('')

  @refreshNotes: (notes) ->
    $('.client-notes-list ul').html(notes)

class ResponsesFilter

  @init: ->
    @bindDropdown()
    @styleDropdown()
    mixpanel.track_forms '#responses-filter-form', 'Concept boards filtered'

  @bindDropdown: ->
    $('.sortBySelect').change (event)=>
      answer = $(event.target).val()
      @sendFilterForm(answer)

  @sendFilterForm: (answer)->
    $form = $('#responses-filter-form')
    $form.find('[name="answer"]').val(answer)
    $form.find('[type=submit]').click()

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
    mixpanel.track('Reviewer invited', { username: username, email: email, contest_id: @contestId })
    $.ajax(
      data: { reviewer_invitation: { username: username, email: email }, contest_id: @contestId }
      url: '/reviewer_invitations'
      type: 'POST'
      success: (response)=>
        @inviteOnSuccess($button, response)
      error: ->
        $button.text('Invite (error occured during last try)')
    )

  @inviteOnSuccess: ($button, response)->
    $row = $button.closest('.invitation-row')
    @updateRow($row, response)
    $row.remove()
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

  @invitableRows: ->
    $(InvitationInputs.container).find('.invitation-row.lnk_container')

$ ->
  EntriesPage.init()

  $(window).load ->
    DesignerBlocks.fitHeight()
  $(window).resize ->
    DesignerBlocks.fitHeight()

class @ResponseEditor

  init: ->
    ContestPreview.initColorPickers()
    @bindSubmitButton()
    @bindSaveButton()
    @bindCommentsSendButton()

    mixpanel.track_forms '#new_contest_request', 'Contest creation - Preview', (form)->
      $form = $(form)
      { data: $form.serializeArray() }

  bindSubmitButton: ->
    $('.submit-button').click (event)=>
      event.preventDefault()
      $('#contest_request_status').val('submitted')
      $('.response').submit()

  bindSaveButton: ->
    $('.footer .submitMyDesign').click (event)=>
      event.preventDefault()
      $('#new_contest_request [type=submit]').click()

  bindCommentsSendButton: ->
    $('.sidebarComments .send-button').click (event)=>
      event.preventDefault()
      $button = $(event.target)
      $comment = $button.parents('.sidebarComments').find('[name=text]')
      return unless $.trim($comment.val())
      contestId = $button.parents('.contest').data('id')
      @sendComment(contestId, $comment)

  sendComment: (contestId, $comment)->
    $.ajax(
      data: { comment: { text: $comment.val(), contest_id: contestId } }
      url: '/contest_requests/add_comment'
      type: 'POST'
      success: ()=>
        $comment.val('')
        @showNoticeQuestionSent()
    )

  showNoticeQuestionSent: ->
    $noticeContainer = $('.question-sent-notice')
    $noticeContainer.css('display', 'inline-block').delay(1000)
    $noticeContainer.fadeOut()

preventBrowserAutofill = (input)->
  $(input).val('')

$ ->
  responseEditor = new ResponseEditor()
  responseEditor.init()
  ConceptBoardUploader.init(i18n: window.conceptBoardUploaderI18n, single: true)
  preventBrowserAutofill(ConceptBoardUploader.imageIdSelector)
  Colors.set()

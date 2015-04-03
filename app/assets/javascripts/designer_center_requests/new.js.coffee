class @ResponseEditor

  init: ->
    ContestPreview.initColorPickers()
    @bindSubmitButton()
    @bindSaveButton()
    @bindCommentsSendButton()

  bindSubmitButton: ->
    $('.submit-button').click (event)=>
      event.preventDefault()
      $('#contest_request_status').val('submitted')
      $('.response').submit()

  bindSaveButton: ->
    $('.footer .submitMyDesign').click (event)=>
      event.preventDefault()
      $('#new_contest_request').submit()

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
       data: { contest_note: { text: $comment.val(), contest_id: contestId } }
       url: '/contest_notes'
       type: 'POST'
       success: (data)->
         $comment.val('')
     )

$ ->
  responseEditor = new ResponseEditor()
  responseEditor.init()
  ConceptBoardUploader.init(window.conceptBoardUploaderI18n)
  Colors.set()

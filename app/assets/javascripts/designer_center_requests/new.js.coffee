class @ResponseEditor

  init: ->
    ContestPreview.init()
    @bindSubmitButton()
    @bindSaveButton()

  bindSubmitButton: ->
    $('.submit-button').click (event)=>
      event.preventDefault()
      $('#contest_request_status').val('submitted')
      $('.response').submit()

  bindSaveButton: ->
    $('.footer .submitMyDesign').click (event)=>
      event.preventDefault()
      $('#new_contest_request').submit()

$ ->
  responseEditor = new ResponseEditor()
  responseEditor.init()
  ConceptBoardUploader.init(window.conceptBoardUploaderI18n)
  Colors.set()

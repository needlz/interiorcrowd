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
    $('.footer .save-and-preview').click (event)=>
      event.preventDefault()
      $('.response').submit()


$ ->
  responseEditor = new ResponseEditor()
  responseEditor.init()

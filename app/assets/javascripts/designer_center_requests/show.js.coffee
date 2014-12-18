class @MoodboardEditor extends InlineEditor

  placeholderSelector: '.notes'
  attributeIdentifierData: 'attribute'

  bindEvents: ->
    super()
    @bindSaveClick()

  bindSaveClick: ->
    $('body').on('click', '.attribute .save-button', @onSaveClick)

  onSaveSuccess: (attribute) ->
    (result)=>
      $optionsRow = $(".response .attribute[data-#{ @attributeIdentifierData }=#{ attribute }]")
      $optionsRow.find('.error').hide()
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $('.response .designer-notes-value').val(result[attribute].value)
      $optionsRow.find('.view').html(result[attribute].html)

  onSaveError: (attribute)->
    (result)=>
      $optionsRow = $(".response .attribute[data-#{ @attributeIdentifierData }='#{ attribute }']")
      $optionsRow.find('.error').text 'An error occured during saving'

  getForm: (attribute)->
    $response = $('.response')
    responseId = $response.data('id')
    $editForm = $('#notes-edit-dialog').clone().data('id', responseId)
    designerNotes = $response.find('.designer-notes-value').val()
    $editForm.find('.notes').val(designerNotes).text(designerNotes)
    @onEditFormRetrieved(attribute, $editForm.html())

  contestId: ->
    $('.contest').data('id')

  afterEditFormRetrieved: (attribute, formHtml)->
    $saveButton = $("[data-attribute=#{ attribute }]").find('.save-button')
    $saveButton.show()

  onSaveClick: (event)=>
    $saveButton = $(event.target)
    $attribute = $saveButton.parents('.attribute')
    attribute = $attribute.data(@attributeIdentifierData)
    responseId = $saveButton.parents('.response').data('id')
    feedback = $saveButton.parents('.edit').find('#contest_request_feedback').val()
    $.ajax(
      url: $attribute.data('url'),
      dataType: 'json'
      method: 'PATCH',
      data:
        contest_request:
          feedback: feedback
      success: @onSaveSuccess(attribute)
      error: @onSaveError(attribute)
    )

class @ResponseView

  init: ->
    moodboardEditor = new MoodboardEditor()
    moodboardEditor.bindEvents()
    @bindSubmissionButton()

  bindSubmissionButton: ->
    $('#designer-response-view .submit').click (event)->
      event.preventDefault()
      $('.edit_contest_request').submit()

$ ->
  responseView = new ResponseView()
  responseView.init()
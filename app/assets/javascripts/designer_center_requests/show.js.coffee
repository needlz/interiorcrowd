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
      $optionsRow = $(".respond .attribute[data-#{ @attributeIdentifierData }=#{ attribute }]")
      $optionsRow.find('.error').hide()
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $('.respond .designer-notes-value').val(result[attribute].value)
      $optionsRow.find('.view').html(result[attribute].html)

  onSaveError: (attribute)->
    (result)=>
      $optionsRow = $(".respond .attribute[data-#{ @attributeIdentifierData }='#{ attribute }']")
      $optionsRow.find('.error').text 'An error occured during saving'

  getForm: (attribute)->
    $respond = $('.respond')
    respondId = $respond.data('id')
    $editForm = $('#notes-edit-dialog').clone().data('id', respondId)
    designerNotes = $respond.find('.designer-notes-value').val()
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
    respondId = $saveButton.parents('.respond').data('id')
    feedback = $saveButton.parents('.edit').find('#respond_feedback').val()
    $.ajax(
      url: $attribute.data('url'),
      method: 'PATCH',
      data:
        respond:
          feedback: feedback
      success: @onSaveSuccess(attribute)
      error: @onSaveError(attribute)
    )

$ ->
  moodboardEditor = new MoodboardEditor()
  moodboardEditor.bindEvents()

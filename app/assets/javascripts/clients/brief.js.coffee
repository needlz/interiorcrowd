class @ContestEditing extends InlineEditor

  attributeIdentifierData: 'option'
  placeholderSelector: '.attribute-form'

  bindEvents: ->
    super()
    @bindSaveClick()
    @bindSaveSuccess()
    @bindSaveError()
    @initPreview()

  initPreview: ->
    $(@attributeSelector).filter("[data-#{ @attributeIdentifierData }]").each((index, element)=>
      attribute = $(element).data(@attributeIdentifierData)
      @previewCallbacks[attribute]?()
    )

  bindSaveClick: ->
    $('body').on('click', '.edit-profile .save-button', @onSaveClick)

  bindSaveSuccess: ->
    $('body').on('ajax:success', '.edit-profile form', (event, data, status, xhr)=>
      $form = $(event.target)
      option = $form.parents('[data-option]').data('option')
      $editButton = $(".edit-profile[data-option='#{ option }'] .edit-button")
      $optionsRow = @optionsRow($editButton)
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $optionsRow.find('.preview').html(data)
      @previewCallbacks[option]?()
    )

  bindSaveError: ->
    $('body').on('ajax:error', '.edit-profile form', (event, data, status, xhr)=>
      $form = $(event.target)
      @optionsContainer($form).find('.has-error .control-label').text 'An error occured during saving'
    )

  getForm: (attribute)->
    $.ajax(
      data: { option: attribute }
      url: @formHtmlPath()
      success: (formHtml)=>
        @onEditFormRetrieved(attribute, formHtml)
    )

  contestId: ->
    $('.contest').data('id')

  optionsContainer: ($childElement)->
    @optionsRow($childElement).find('.attribute-form .view')

  formHtmlPath: ->
    "/contests/#{ @contestId() }/option"

  afterEditFormRetrieved: (attribute, formHtml)->
    $saveButton = $("[data-option=#{ attribute }]").find('.save-button')
    $saveButton.show()

  editFormsCallbacks:
    space_pictures: ->
      console.log('aa')
      SpacePicturesUploader.init()
    example_pictures: ->
      console.log('aa')
      ExamplesUploader.init()
    desirable_colors: ->
      console.log('aa')
      DesirableColorsEditor.init()
    undesirable_colors: ->
      console.log('aa')
      UndesirableColorsEditor.init()
    area: ->
      console.log('aa')
      RoomsEditor.init()
    appeals: ->
      console.log('aa')
      AppealsForm.init()
    budget: ->
      console.log('aa')
      BudgetOptions.init()

  previewCallbacks:
    desirable_colors: ->
      ContestPreview.init()
    undesirable_colors: ->
      ContestPreview.init()

  onSaveClick: (event)=>
    $saveButton = $(event.target)
    $saveButton.parents('form').submit()

$ ->
  window.brief = new ContestEditing()
  brief.bindEvents()

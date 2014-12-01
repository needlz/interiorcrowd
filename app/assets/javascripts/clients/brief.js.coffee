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
    $('body').on('click', '.attribute .save-button', @onSaveClick)

  bindSaveSuccess: ->
    $('body').on('ajax:success', '.attribute form', (event, data, status, xhr)=>
      $form = $(event.target)
      option = $form.parents('[data-option]').data('option')
      $editButton = $(".row[data-option='#{ option }'] .edit-button")
      $optionsRow = @optionsRow($editButton)
      @cancelEditing($optionsRow.data(@attributeIdentifierData))
      $optionsRow.find('.preview').html(data)
      @previewCallbacks[option]?()
    )

  bindSaveError: ->
    $('body').on('ajax:error', '.attribute form', (event, data, status, xhr)=>
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
      SpacePicturesUploader.init()
    example_pictures: ->
      ExamplesUploader.init()
    desirable_colors: ->
      DesirableColorsEditor.init()
    undesirable_colors: ->
      UndesirableColorsEditor.init()
    area: ->
      designArea = new DesignArea($('#design_brief_design_area'), $('.area-children'), areas)
      designArea.init()

  previewCallbacks:
    desirable_colors: ->
      $('.colors').colorTags({ readonly: true })
    undesirable_colors: ->
      $('.colors').colorTags({ readonly: true })

  onSaveClick: (event)=>
    $saveButton = $(event.target)
    $saveButton.parents('form').submit()

$ ->
  window.brief = new ContestEditing()
  brief.bindEvents()

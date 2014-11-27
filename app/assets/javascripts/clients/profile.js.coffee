class @ProfileEditor

  bindEvents: ->
    @bindEditClick()
    @bindSaveSuccess()
    @bindSaveError()
    @initPreview()

  initPreview: ->
    $('.attribute[data-id]').each((index, element)=>
      attribute = $(element).data('attribute')
      @previewCallbacks[option]?()
    )

  bindEditClick: ->
    $('.attribute .edit-button').click(@onEditClick)

  onEditClick: (event)=>
    $button = $(event.target)
    attribute = $button.parents('.attribute').data('id')
    @insertOptionsHtml(attribute)

  formPlaceholder: ($childElement)->
    @optionsRow($childElement).find('.placeholder')

  optionsHtmlPath: ->
    "/clients/#{ @contestId() }/option"

  requestAttributeForm: (attribute)->
    $.ajax(
      data: { option: option }
      url: @attributeFormPath()
      success: (formHtml)=>
        @onEditFormRetrieved(attribute, formHtml)
    )

  onEditFormRetrieved: (attribute, formHtml)=>
    $editButton = $(".attribute[data-id='#{ attribute }'] .edit-button")
    $editButton.text(I18n)
    $editButton.off('click').click(@onCancelClick)
    $optionsRow = @optionsRow($editButton)
    $optionContainer = $optionsRow.find('.attribute-form .view')
    $saveButton = $optionsRow.find('.save-button')
    $saveButton.show()
    $preview = $optionContainer.clone()
    $optionContainer.html(optionsHtml)
    $preview.addClass('edit-form').removeClass('view').hide().insertAfter($optionContainer)
    @editFormsCallbacks[option]?()

  onCancelClick: (event)=>
    $editButton = $(event.target)
    @cancelEditing($editButton)

  cancelEditing: ($editButton)->
    $editButton.text('Edit')
    $optionsRow = @optionsRow($editButton)
    $optionsRow.find('.save-button').hide()
    $preview = $optionsRow.find('.edit-form')
    $options = $optionsRow.find('.attribute-form .view')
    $options.replaceWith($preview)
    $preview.show().removeClass('edit-form').addClass('view')
    $editButton.off('click').click(@onEditClick)


  optionsRow: ($child)->
    $child.parents('.row[data-option]')

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
  profile = new ProfileEditor()
  profile.bindEvents()

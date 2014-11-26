class @ContestEditing

  bindEditForms: ->
    @bindSaveClick()
    @bindEditClick()
    @bindSaveSuccess()
    @bindSaveError()
    @initPreview()

  initPreview: ->
    $('.attribute[data-option]').each((index, element)=>
      option = $(element).data('option')
      @previewCallbacks[option]?()
    )

  bindEditClick: ->
    $('.attribute .edit-label').click(@onEditClick)

  bindSaveClick: ->
    $('body').on('click', '.attribute .save-button', @onSaveClick)

  bindSaveSuccess: ->
    $('body').on('ajax:success', '.attribute form', (event, data, status, xhr)=>
      $form = $(event.target)
      option = $form.parents('[data-option]').data('option')
      $editButton = $(".row[data-option='#{ option }'] .edit-label")
      @cancelEditing($editButton)
      $optionsRow = @optionsRow($editButton)
      $optionsRow.find('.preview').html(data)
      @previewCallbacks[option]?()
    )

  bindSaveError: ->
    $('body').on('ajax:error', '.attribute form', (event, data, status, xhr)=>
      $form = $(event.target)
      @optionsContainer($form).find('.has-error .control-label').text 'An error occured during saving'
    )

  onEditClick: (event)=>
    $button = $(event.target)
    option = $button.parents('[data-option]').data('option')
    @insertOptionsHtml(option)

  contestId: ->
    $('.contest').data('id')

  optionsContainer: ($childElement)->
    @optionsRow($childElement).find('.attribute-form .view')

  optionsHtmlPath: ->
    "/contests/#{ @contestId() }/option"

  insertOptionsHtml: (option)->
    $.ajax(
      data: { option: option }
      url: @optionsHtmlPath()
      success: (optionsHtml)=>
        @onEditFormRetrieved(option, optionsHtml)
    )

  onEditFormRetrieved: (option, optionsHtml)=>
    $editButton = $(".row[data-option='#{ option }'] .edit-label")
    $editButton.text('Cancel')
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
  window.brief = new ContestEditing()
  brief.bindEditForms()

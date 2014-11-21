class @ContestEditing

  bindEditPopovers: ->
    $('.edit-label').click(@onEditClick)

  onEditClick: (event)=>
    $button = $(event.target)
    option = $button.parents('[data-option]').attr('data-option')
    @insertOptionsHtml(option)

  contestId: ->
    $('.contest').attr('data-id')

  optionsContainer: ($childElement)->
    @optionsRow($childElement).find('.value')

  optionsHtmlPath: ->
    "/contests/#{ @contestId() }/option"

  insertOptionsHtml: (option)->
    $.ajax(
      data: { option: option }
      url: @optionsHtmlPath()
      success: (optionsHtml)=>
        @onOptionsRetrieved(option, optionsHtml)
    )

  onOptionsRetrieved: (option, optionsHtml)=>
    $editButton = $(".row[data-option='#{ option }'] .edit-label")
    $editButton.text('Cancel')
    $editButton.off('click').click(@onCancelClick)
    $optionContainer = @optionsRow($editButton).find('.value')
    $preview = $optionContainer.clone()
    $optionContainer.html(optionsHtml)
    $preview.addClass('preview').removeClass('value').hide().insertAfter($optionContainer)
    @attributeCallbacks[option]?()

  onCancelClick: (event)=>
    $editButton = $(event.target)
    $editButton.text('Edit')
    $optionsRow = @optionsRow($editButton)
    $preview = $optionsRow.find('.preview')
    $options = $optionsRow.find('.value')
    $options.replaceWith($preview)
    $preview.show().removeClass('preview').addClass('value')
    $editButton.off('click').click(@onEditClick)

  optionsRow: ($child)->
    $child.parents('.row[data-option]')

  attributeCallbacks:
    space_pictures: ->
      SpacePicturesUploader.init()
    example_pictures: ->
      ExamplesUploader.init()
    desirable_colors: ->
      DesirableColorsEditor.init()
    undesirable_colors: ->
      UndesirableColorsEditor.init()

$ ->
  window.brief = new ContestEditing()
  brief.bindEditPopovers()

  $('.colors').colorTags({ readonly: true })

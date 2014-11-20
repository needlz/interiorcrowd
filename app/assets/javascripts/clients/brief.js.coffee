class @ContestEditing

  bindEditPopovers: ->
    $('.edit-label').click (event)=>
      $button = $(event.target)
      option = $button.parents('[data-option]').attr('data-option')
      $container = @optionsContainer($button)
      @insertOptionsHtml($container, option)

  contestId: ->
    $('.contest').attr('data-id')

  optionsContainer: ($childElement)->
    $childElement.parents('.row[data-option]')

  optionsHtmlPath: ->
    "/contests/#{ @contestId() }/option"

  insertOptionsHtml: ($optionContainer, option)->
    $.ajax(
      data: { option: option }
      url: @optionsHtmlPath()
      success: (optionHtml)->
        $optionContainer.html(optionHtml)
    )

$ ->
  brief = new ContestEditing()
  brief.bindEditPopovers()

  $('.colors').colorTags({ readonly: true })

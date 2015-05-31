class ImageItemsTextFolding
  @textSelector: '.productsMoodboardAbove'
  @collapseButtonSelector: '.collapse-button'
  @aboutMaxHeightPx: 70
  @imageItemSelector: '.image-item'

  @init: ->
    $(@textSelector).dotdotdot height: @aboutMaxHeightPx
    $(@imageItemSelector).find(@collapseButtonSelector).off('click').click(@onFoldButtonClick)

  @onFoldButtonClick: (event) =>
    event.preventDefault()
    $button = $(event.target)
    $imageItem = $button.parents(@imageItemSelector)
    $text = $imageItem.find(@textSelector)

    if $text.data().dotdotdot
      @expand($button, $text)
    else
      @collapse($button, $text)

  @expand: ($button, $text)->
    $text.trigger 'destroy.dot'
    $button.text(productListI18n.collapse)

  @collapse: ($button, $text)->
    $text.dotdotdot height: @aboutMaxHeightPx
    $button.text(productListI18n.expand)

$ ->
  ImageItemsTextFolding.init()

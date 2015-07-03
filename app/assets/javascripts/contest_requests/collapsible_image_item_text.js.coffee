class ImageItemsTextFolding
  @textSelector: '.about-text'

  @init: ->
    $(@textSelector).enscroll({
      verticalTrackClass: 'scrollBoxCommentsTrack',
      verticalHandleClass: 'scrollBoxCommentsHandle',
      minScrollbarLength: 28
    })

$ ->
  ImageItemsTextFolding.init()

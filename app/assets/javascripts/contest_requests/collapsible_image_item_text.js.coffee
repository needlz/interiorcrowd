class @ImageItemsTextFolding
  @textSelector: '.about-text'

  @init: ->
    $(@textSelector).customScrollBar()

$ ->
  ImageItemsTextFolding.init()

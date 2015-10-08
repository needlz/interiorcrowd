class @PicturesZoom

  @fitToScreenOptions: { maxWidth: '100%', maxHeight: '100%' }

  @smallScreen: ->
    window.matchMedia('(max-width: 768px)').matches

  @getOptionsUpdater: ($element, options)->
    =>
      fitToScreen = !@smallScreen()
      newOptions = $.extend({}, options)
      if fitToScreen
        $.extend(newOptions, @fitToScreenOptions)
      $element.colorbox(newOptions)

  @init: (enlargeButtonSelector)->
    @setWithOptionsUpdater(enlargeButtonSelector, {})

  @initGallery: (options)->
    @setWithOptionsUpdater(options.enlargeButtonSelector, { rel: options.galleryName })

  @setWithOptionsUpdater: (selector, options)->
    $element = $(selector)
    optionsUpdater = @getOptionsUpdater($element, options)
    optionsUpdater()

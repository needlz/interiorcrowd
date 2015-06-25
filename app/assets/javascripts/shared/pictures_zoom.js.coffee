class @PicturesZoom

  @fitToScreenOptions: { maxWidth: '100%', maxHeight: '100%' }

  @smallScreen: ->
    window.matchMedia('(max-width: 768px)').matches

  @getOptionsUpdater: (selector, options)->
    =>
      fitToScreen = !@smallScreen()
      newOptions = $.extend({}, options)
      if fitToScreen then $.extend(newOptions, @fitToScreenOptions)
      console.log $(selector)
      $(selector).colorbox.remove()
      $(selector).colorbox(newOptions)

  @init: (enlargeButtonSelector)->
    @setWithOptionsUpdater(enlargeButtonSelector, {})

  @initGallery: (options)->
    @setWithOptionsUpdater(options.enlargeButtonSelector, { rel: options.galleryName })

  @setWithOptionsUpdater: (selector, options)->
    $element = $(selector)
    $element.colorbox(options)

    optionsUpdater = @getOptionsUpdater(selector, options)
    optionsUpdater()
    $(window).resize ->
      optionsUpdater()

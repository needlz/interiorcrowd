class @PicturesZoom

  @fitToScreenOptions: { maxWidth: '100%', maxHeight: '100%' }

  @smallScreen: ->
    window.matchMedia('(max-width: 768px)').matches

  @getOptionsUpdater: ($element, options)->
    fitToScreen = @smallScreen()
    newColorboxOptions = $.extend({ title: false }, options)
    if fitToScreen
      $.extend(newColorboxOptions, @fitToScreenOptions)
    if newColorboxOptions.pictureSelector && fitToScreen
      newColorboxOptions.href = $element.attr('href')
      console.log newColorboxOptions.href
      $element.closest(newColorboxOptions.pictureSelector).colorbox(newColorboxOptions) if newColorboxOptions.href
    else
      $element.colorbox(newColorboxOptions)

  @init: (enlargeButtonSelector, options)->
    @setWithOptionsUpdater(enlargeButtonSelector, options)

  @initGallery: (options)->
    @setWithOptionsUpdater(options.enlargeButtonSelector, { rel: options.galleryName })

  @setWithOptionsUpdater: (selector, options)->
    $elements = $(selector)
    $elements.each (index, element)=>
      $element = $(element)
      @getOptionsUpdater($element, options)

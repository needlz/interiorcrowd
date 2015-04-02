class @PicturesZoom

  @init: (buttonSelector)->
    $(buttonSelector).colorbox()

  @initGallery: (options)->
    $(options.buttonSelector).colorbox(rel: options.galleryName)

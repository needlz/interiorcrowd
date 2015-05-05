class @PicturesZoom

  @init: (enlargeButtonSelector)->
    $(enlargeButtonSelector).colorbox()

  @initGallery: (options)->
    $(options.enlargeButtonSelector).colorbox(rel: options.galleryName)

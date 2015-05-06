class @PicturesZoom

  @init: (enlargeButtonSelector)->
    $(enlargeButtonSelector).colorbox(maxWidth: '100%', maxHeight: '100%')

  @initGallery: (options)->
    $(options.enlargeButtonSelector).colorbox(rel: options.galleryName, maxWidth: '100%', maxHeight: '100%')

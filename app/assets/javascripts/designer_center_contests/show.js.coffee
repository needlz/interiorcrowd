$ ->
  ContestPreview.init()

  PicturesZoom.init('.imageWithOverlay a')
  PicturesZoom.initGallery(buttonSelector: '[data-id=space_pictures] a', galleryName: 'space')
  PicturesZoom.initGallery(buttonSelector: '[data-id=example_pictures] a', galleryName: 'examples')

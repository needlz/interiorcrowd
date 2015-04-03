class DesignerCenterContestBrief

  @init: ->
    ContestPreview.initColorPickers()
    ContestPreview.initStyleCollagesZooming()
    ContestPreview.initStyleDetailsPopups()
    @initExamplesZooming()

  @initExamplesZooming: ->
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=space_pictures] a', galleryName: 'space')
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=example_pictures] a', galleryName: 'examples')

$ ->
  DesignerCenterContestBrief.init()

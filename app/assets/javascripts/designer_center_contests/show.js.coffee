class DesignerCenterContestBrief

  @init: ->
    ContestPreview.initColorPickers()
    ContestPreview.initStyleCollagesZooming()
    ContestPreview.initStyleDetailsPopups()
    @initExamplesZooming()

  @initExamplesZooming: ->
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=space_pictures] a.enlarge', galleryName: 'space')
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=example_pictures] a.enlarge', galleryName: 'examples')

$ ->
  DesignerCenterContestBrief.init()

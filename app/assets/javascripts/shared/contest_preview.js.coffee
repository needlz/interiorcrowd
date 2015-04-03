class @ContestPreview

  @initColorPickers: ->
    $('.colors').colorTags({ readonly: true })

  @initStyleCollagesZooming: ->
    PicturesZoom.init('.designStyleParent .imageWithOverlay a')

  @initStyleDetailsPopups: ->
    $('[data-toggle="popover"]').popover(viewport: '.designStyleParent', container: '.designStyleParent')
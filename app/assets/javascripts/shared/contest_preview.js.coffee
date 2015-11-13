class @ContestPreview

  @initColorPickers: ->
    $('.colors').colorTags({ readonly: true })

  @initStyleCollagesZooming: ->
    setTimeout(
      =>
        PicturesZoom.init('.designStyleParent .imageWithOverlay a')
      0
    )
  @initStyleDetailsPopups: ->
    $('[data-toggle="popover"]').popover(viewport: '.designStyleParent', container: '.designStyleParent')

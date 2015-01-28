class @AppealsForm

  @init: ()->
    $(".live-tiles").filter(
      ->
        !$(@).data('isotope')
    ).isotope
      layoutMode: 'packery'
      packery:
        gutter: 10
      itemSelector: '.tile'

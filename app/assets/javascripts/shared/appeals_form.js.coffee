class @AppealsForm

  @init: ()->
    $(".live-tiles").isotope
      layoutMode: 'packery'
      packery:
        gutter: 10
      itemSelector: '.tile'

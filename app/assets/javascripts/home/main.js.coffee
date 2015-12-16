updateSizes = ->
  screenWidth = $(window).width()

  containerWidth = $('.container').width()
  arrowsMargin = (screenWidth - containerWidth) / 2 + 20
  $('.bottomCarouselHome .carousel-control.left').css 'margin-left', arrowsMargin + 'px'
  $('.bottomCarouselHome .carousel-control.right').css 'margin-right', arrowsMargin + 'px'

initClientSlider = ->
  $('.client-stories-slider').slick
    dots: true,
    infinite: true,
    speed: 0,
    fade: true,
    cssEase: 'ease',
    slidesToShow: 1,
    slidesToScroll: 1

initClientBgSlider = ->
  $('.client-bg-slider').slick
    dots: false,
    infinite: true,
    speed: 300,
    fade: true,
    slidesToShow: 1,
    slidesToScroll: 1,
    draggable: false

initDesignerSlider = ->
  $('.designers-slider').slick
    dots: true
    infinite: false
    speed: 300
    slidesToShow: 3
    slidesToScroll: 3
    responsive: [
      {
        breakpoint: 1025
        settings:
          slidesToShow: 2
          slidesToScroll: 2
          infinite: true
          dots: true
      }
      {
        breakpoint: 992
        settings:
          slidesToShow: 2
          slidesToScroll: 2
          infinite: true
      }
      {
        breakpoint: 767
        settings:
          slidesToShow: 1
          slidesToScroll: 1
      }
    ]

alignClientSliderHeight = ->
  clientHeight = $('.client-stories').innerHeight()
  $('.client-bg-slide').css
    height: clientHeight

synchronizeClientSliders = ->
  $('.client-stories-slider').on 'beforeChange', (event, slick, currentSlide, nextSlide) ->
    $('.client-bg-slider').slick 'slickGoTo', nextSlide

$(document).ready ->
  screenWidth = $(window).width()
  $('img').one('load', ->
    if screenWidth >= 768
      $($('.itemBoxRight')).css 'height', $('.itemBoxLeft').height() + 'px'

  ).each ->
    if @complete
      $(this).load()

  $('#scrollBoxComments,.dcProductDesc').enscroll
    verticalTrackClass: 'scrollBoxCommentsTrack'
    verticalHandleClass: 'scrollBoxCommentsHandle'
    minScrollbarLength: 28

  $('.circleDownArrow').click ->
    $('html, body').animate { scrollTop: $('.whatWeDoBox').offset().top }, 700

  updateSizes()

  initClientSlider()
  initClientBgSlider()
  initDesignerSlider()

$(window).load ->
  updateSizes()
  alignClientSliderHeight()
  synchronizeClientSliders()

$(window).resize ->
  updateSizes()
  initClientSlider()
  initClientBgSlider()
  initDesignerSlider()
  alignClientSliderHeight()

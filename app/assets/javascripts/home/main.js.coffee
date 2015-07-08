$(document).ready ->
  screenWidth = $(window).width()
  $('img').one('load', ->
    if screenWidth >= 768
      $($('.itemBoxRight')).css 'height', $('.itemBoxLeft').height() + 'px'

  ).each ->
    if @complete
      $(this).load()

  $('#showcase').awShowcase
    content_width: 750
    content_height: 662
    fit_to_parent: false
    auto: false
    interval: 3000
    continuous: false
    loading: true
    tooltip_width: 200
    tooltip_icon_width: 32
    tooltip_icon_height: 32
    tooltip_offsetx: 18
    tooltip_offsety: 0
    arrows: true
    buttons: true
    btn_numbers: true
    keybord_keys: true
    mousetrace: false
    pauseonover: true
    stoponclick: true
    transition: 'hslide'
    transition_delay: 300
    transition_speed: 500
    show_caption: 'onhover'
    thumbnails: true
    thumbnails_position: 'outside-last'
    thumbnails_direction: 'horizontal'
    thumbnails_slidex: 1
    dynamic_height: false
    speed_change: false
    viewline: false

  $('#scrollBoxComments,.dcProductDesc').enscroll
    verticalTrackClass: 'scrollBoxCommentsTrack'
    verticalHandleClass: 'scrollBoxCommentsHandle'
    minScrollbarLength: 28

  $('.circleDownArrow').click ->
    $('html, body').animate { scrollTop: $('.whatWeDoBox').offset().top }, 700

  if screenWidth > 991
    $('.justineRight').css 'height', +$('.justineLeft').height() + 'px'

  containerWidth = $('.container').width()
  arrowsMargin = (screenWidth - containerWidth) / 2 + 25
  $('.bottomCarouselHome .carousel-control.left').css 'margin-left', arrowsMargin + 'px'
  $('.bottomCarouselHome .carousel-control.right').css 'margin-right', arrowsMargin + 'px'

$(window).resize ->
  screenWidth = $(window).width()
  if screenWidth > 991
    $('.justineRight').css 'height', +$('.justineLeft').height() + 'px'
  screenWidth = $(window).width()
  containerWidth = $('.container').width()
  arrowsMargin = (screenWidth - containerWidth) / 2 + 20
  $('.bottomCarouselHome .carousel-control.left').css 'margin-left', arrowsMargin + 'px'
  $('.bottomCarouselHome .carousel-control.right').css 'margin-right', arrowsMargin + 'px'

updateSizes = ->
  screenWidth = $(window).width()
  $('.justineRight').css 'height', +$('.justineLeft').height() + 'px'

  containerWidth = $('.container').width()
  arrowsMargin = (screenWidth - containerWidth) / 2 + 20
  $('.bottomCarouselHome .carousel-control.left').css 'margin-left', arrowsMargin + 'px'
  $('.bottomCarouselHome .carousel-control.right').css 'margin-right', arrowsMargin + 'px'


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

$(window).load ->
  updateSizes()

$(window).resize ->
  updateSizes()

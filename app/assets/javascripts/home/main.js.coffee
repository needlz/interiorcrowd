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
        breakpoint: 1199
        settings:
          slidesToShow: 2
          slidesToScroll: 2
          infinite: true
      }
      {
        breakpoint: 767
        settings:
          infinite: true
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

bindScrollDownButton = ->
  $('.circleDownArrow').click ->
    $('html, body').animate { scrollTop: $('.whatWeDoBox').offset().top }, 700

bindSignUpButton = ->
  $('a.sign-up-from-homepage').click (e) ->
    e.preventDefault()

    $("#err_email").text('')
    $('#client_email').css('margin-bottom', 18 + 'px')

    $("#err_passwd").text('')
    $('#client_password').css('margin-bottom', 18 + 'px')



    $('.getStartedBottomForm form').submit() if validateClientEmail() && validateClientPassword()

validateClientEmail = ->
  @emailSelector = '#client_email'
  @validator = new ValidationMessages()

  @validator.reset()

  email = $.trim($(@emailSelector).val())
  email_regex = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i
  unless email.match email_regex
    @validator.addMessage $("#err_email"), 'Please input valid email', $('.getStartedBottomForm')
    $('#client_email').css('margin-bottom', 0)
    $('#client_email').focus()
  unless email.length
    @validator.addMessage $("#err_email"), 'Email field can not be blank', $('.getStartedBottomForm')
    $('#client_email').css('margin-bottom', 0)
    $('#client_email').focus()

  @validator.valid

validateClientPassword = ->
  @passwdSelector = '#client_password'
  @validator = new ValidationMessages()

  @validator.reset()

  passwd = $.trim($(@passwdSelector).val())
  unless passwd.length
    @validator.addMessage $("#err_passwd"), 'Password field can not be blank', $('.getStartedBottomForm')
    $('#client_password').css('margin-bottom', 0)
    $('#client_password').focus()

  @validator.valid

$(document).ready ->
  screenWidth = $(window).width()
  $('img').one('load', ->
    if screenWidth >= 768
      $($('.itemBoxRight')).css 'height', $('.itemBoxLeft').height() + 'px'
  ).each ->
    if @complete
      $(this).load()

  $('#scrollBoxComments').customScrollBar()

  bindScrollDownButton()
  bindSignUpButton()
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

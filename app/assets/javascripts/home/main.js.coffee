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

initCTAButtons = ->
  $('a.getStartedBtn').click (e) ->
    e.preventDefault()
    scrollToButton()

scrollToButton = ->
  $('#body-footer').scrollintoview
    duration: 2500
    direction: "y"
    complete: ->
      $('#client_name').focus()

initStickyNavigation = ->
  displayStickyNav()
  $(window).scroll ->
    displayStickyNav()

initCTAButtons = ->
  $('a.getStartedBtn, a.getStartedSticky').click (e) ->
    e.preventDefault()
    scrollToButton()

scrollToButton = ->
  $('#body-footer').scrollintoview
    duration: 2500
    direction: "y"
    complete: ->
      $('#client_name').focus()

alignClientSliderHeight = ->
  clientHeight = $('.client-stories').innerHeight()
  $('.client-bg-slide').css
    height: clientHeight

synchronizeClientSliders = ->
  $('.client-stories-slider').on 'beforeChange', (event, slick, currentSlide, nextSlide) ->
    $('.client-bg-slider').slick 'slickGoTo', nextSlide

bindCustomScrollbar = ->
  $('#scrollBoxComments').customScrollBar()

bindScrollDownButton = ->
  $('.circleDownArrow').click ->
    $('html, body').animate { scrollTop: $('.whatWeDoBox').offset().top }, 700

bindSignUpButton = ->
  $('a.sign-up-from-homepage').click (e) ->
    e.preventDefault()

    removeErrors()

    ajaxParams = requestOptions('.form-body form')

    $.ajax(ajaxParams) if validateClientEmail() && validateClientPassword()

requestOptions = (formSelector) ->
  $form = $(formSelector).serializeArray()

  data: $form
  url: '/clients/sign_up_with_email'
  method: 'POST'
  dataType: 'json'
  success: (json) ->
    location.href = '/contests/design_brief'
  error: (response)=>
    showAlert(response.responseJSON.error)

removeErrors = ->
  $("#err_email").text('')
  $('#client_email').css('margin-bottom', 18 + 'px')

  $("#err_passwd").text('')
  $('#client_password').css('margin-bottom', 18 + 'px')

showAlert = (errorMessage) ->
  @validator.addMessage $("#err_email"), errorMessage, $('.getStartedBottom .form-body')
  $('#client_email').css('margin-bottom', 0)
  $('#client_email').focus()

validateClientEmail = ->
  @emailSelector = '#client_email'
  @validator = new ValidationMessages()

  @validator.reset()

  email = $.trim($(@emailSelector).val())
  email_regex = /^(([^<>()\[\]\.,;:\s@\"]+(\.[^<>()\[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i

  unless email.match email_regex
    @validator.addMessage $("#err_email"), Messages.input_valid_email, $('.getStartedBottom .form-body')
    $('#client_email').css('margin-bottom', 0)
    $('#client_email').focus()

  unless email.length
    @validator.addMessage $("#err_email"), Messages.email_blank, $('.getStartedBottom .form-body')
    $('#client_email').css('margin-bottom', 0)
    $('#client_email').focus()

  @validator.valid

validateClientPassword = ->
  @passwdSelector = '#client_password'
  @validator = new ValidationMessages()

  @validator.reset()

  passwd = $.trim($(@passwdSelector).val())

  unless passwd.length
    @validator.addMessage $("#err_passwd"), Messages.password_blank, $('.getStartedBottom .form-body')
    $('#client_password').css('margin-bottom', 0)
    $('#client_password').focus()

  @validator.valid

detectGetStartedBtn = ->
  return $('.item.active').find('.getStartedBtn')

detectGetStartedBottom= ->
  return $('.getStartedBottomButton')

getStartedBtnTopPosition = ->
  detectGetStartedBtn().offset().top + detectGetStartedBtn().outerHeight(true)

getStartedBottomTopPosition = ->
  detectGetStartedBottom().offset().top

displayStickyNav = ->
  scrollTopPosition = $(window).scrollTop()
  scrollBottomPosition = scrollTopPosition + $(window).height()

  if scrollTopPosition > getStartedBtnTopPosition() && scrollBottomPosition < getStartedBottomTopPosition()
    $('.sticky-nav').addClass('sticky').show()
  else
    $('.sticky-nav').removeClass('sticky').hide()

$(document).ready ->
  screenWidth = $(window).width()
  $('img').one('load', ->
    if screenWidth >= 768
      $($('.itemBoxRight')).css 'height', $('.itemBoxLeft').height() + 'px'
  ).each ->
    if @complete
      $(this).load()

  bindCustomScrollbar()
  bindScrollDownButton()
  bindSignUpButton()
  updateSizes()
  initClientSlider()
  initClientBgSlider()
  initDesignerSlider()
  initCTAButtons()

  initStickyNavigation()
  initCTAButtons()

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

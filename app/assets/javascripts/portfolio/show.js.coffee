class InvitationButton extends DesignerInvitationButton

  @buttonSelector: '.inviteToContest.active'

  @getDesignerId: ($button)->
    $button.parents('.designer-portfolio').data('id')

  @onSuccess: ($button) ->
    $button.text(@I18n().invited).off('click')

  @beforeRequest: ($button)->
    $button.text(@I18n().sending_invitation)

class @Portfolio

  @aboutExpandButtonSelector: '.user_portfolio_profile .about .readmore'
  @aboutTextSelector: '.user_portfolio_profile .about .text'
  @maxAboutHeightPx: 100

  @init: ->
    contestId = $(InvitationButton.buttonSelector).data('contest-id')
    InvitationButton.bindInviteButtons(contestId)

    @initAboutEllipsis()
    $(window).resize =>
      @initAboutEllipsis()

    $(@aboutExpandButtonSelector).click (e)=>
      e.preventDefault()
      @expandAboutBlock()
      $(@aboutExpandButtonSelector).hide()

  @initAboutEllipsis: ->
    $(@aboutTextSelector).dotdotdot({ height: @maxAboutHeightPx })
    if $(@aboutTextSelector).height() < 100
      $(@aboutExpandButtonSelector).hide()

  @expandAboutBlock: ->
    $(@aboutTextSelector).dotdotdot()

class @CoverDragging

  @draggableCoverSelector: '.cover_image'
  @dragLabelSelector: '.bottom-stripe .drag-label'
  @dragMenuSelector: '.bottom-stripe .drag-menu'
  @dragCancelButtonSelector: '.bottom-stripe .drag-cancel'
  @dragSaveButtonSelector: '.bottom-stripe .drag-save'
  @editProfileButtonSelector: '.bottom-stripe .editCover'
  @dragging: false
  @height: null
  @width: null
  @dragging: false
  @initialPosition: null
  @offsetInPercents: null

  @init: ->
    @offsetInPercents = {
      x: $(@draggableCoverSelector).data('x'),
      y: $(@draggableCoverSelector).data('y')
    }

    @bindEvents()
    @startImageSizeCalucaltion()

  @startImageSizeCalucaltion: ->
    @initInterval = setInterval(
      =>
        @recalculatePixels()
        if @width && @height
          clearInterval(@initInterval)
      , 100
    )

  @bindEvents: ->
    $(window).resize =>
      @recalculatePixels()

    $(@dragLabelSelector).click =>
      @startDragging() unless @dragging

    $(@dragCancelButtonSelector).click =>
      @exitDragging()
      @recalculatePixels()

    $(@dragSaveButtonSelector).click =>
      @exitDragging()
      @saveReposition()

  @startDragging: =>
    @dragging = true
    $(@dragLabelSelector).text(I18n.cover_dragging.label)
    $(@draggableCoverSelector).backgroundDraggable();
    @showButtons()

  @recalculateScaledImageSize: =>
    image_url = $(@draggableCoverSelector).css('background-image')
    image_url = image_url.match(/^url\(("|')?(.+?)("|')?\)$/);
    bgW = null
    bgH = null

    image_url = image_url[2]
    background = new Image()

    div = $(@draggableCoverSelector).get(0)

    background.src = image_url

    if background.width > background.height
      ratio = background.height / background.width
      if div.offsetWidth > div.offsetHeight
        bgW = div.offsetWidth
        bgH = Math.round(div.offsetWidth * ratio)
        if bgH < div.offsetHeight
          bgH = div.offsetHeight
          bgW = Math.round(bgH / ratio)
      else
        bgW = Math.round(div.offsetHeight / ratio)
        bgH = div.offsetHeight
    else
      ratio = background.width / background.height
      if div.offsetHeight > div.offsetWidth
        bgH = div.offsetHeight
        bgW = Math.round(div.offsetHeight * ratio)
        if bgW > div.offsetWidth
          bgW = div.offsetWidth
          bgH = Math.round(bgW / ratio)
      else
        bgW = Math.round(div.offsetWidth / ratio)
        bgH = div.offsetWidth

    @height = bgH;
    @width = bgW || div.offsetWidth;

  @saveReposition: =>
    @exitDragging()
    @offsetInPercents = @pixelsToPercents()
    @sendRequest()

  @showButtons: ->
    $(@dragMenuSelector).show()
    $(@editProfileButtonSelector).hide()

  @hideButtons: ->
    $(@dragMenuSelector).hide()
    $(@editProfileButtonSelector).show()

  @exitDragging: ->
    @dragging = false
    @hideButtons()
    $(@draggableCoverSelector).backgroundDraggable('disable');
    $(@dragLabelSelector).text(I18n.cover_dragging.start_dragging)

  @recalculatePixels: ->
    @recalculateScaledImageSize()
    newPosition = "#{ (@offsetInPercents.x * @width / 100) - @width/2 }px #{ (@offsetInPercents.y * @height / 100) - @height/2 }px"
    $(@draggableCoverSelector).css('background-position', newPosition)

  @pixelsToPercents: ->
    pixels = @getPixels()
    y = (pixels.y + @height/2)/(@height)*100
    x = (pixels.x + @width/2)/(@width)*100
    { y: y, x: x }

  @getPixels: ->
    backgroundPosition = $(@draggableCoverSelector).css('background-position')
    displacement = backgroundPosition.split(' ')
    { x: parseFloat(displacement[0]), y: parseFloat(displacement[1]) }

  @sendRequest: =>
    container = $(@draggableCoverSelector).get(0)
    $.ajax(
      data: {
        portfolio: {
          cover_x_percents_offset: @offsetInPercents.x,
          cover_y_percents_offset: @offsetInPercents.y
        }
      }
      url: '/designer_center/portfolio'
      type: 'PATCH'
      dataType: 'json'
    )

$ ->
  Portfolio.init()
  CoverDragging.init()
  PicturesZoom.initGallery(enlargeButtonSelector: '.portfolio_example a.enlarge', galleryName: 'portfolio')
  CoverDragging.recalculateScaledImageSize()

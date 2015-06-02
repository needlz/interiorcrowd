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
  @dragging: false
  @height: null
  @width: null
  @dragging: false
  @initialPosition: null

  @init: ->
    @initialPosition = $(@draggableCoverSelector).css('background-position')
    $(@dragLabelSelector).click =>
      @startDragging() unless @dragging

    $(@dragCancelButtonSelector).click =>
      @exitDragging()
      @revertReposition()

    $(@dragSaveButtonSelector).click =>
      @exitDragging()
      @saveReposition()

  @startDragging: =>
    @dragging = true
    $(@dragLabelSelector).text(I18n.cover_dragging.label)
#    @percentsToPixels()
    $(@draggableCoverSelector).backgroundDraggable(done: =>
      @afterDragged()
    );
    @showButtons()

  @afterDragged: =>
    image_url = $(@draggableCoverSelector).css('background-image')
    image_url = image_url.match(/^url\("?(.+?)"?\)$/);
    bgW = null
    bgH = null

    image_url = image_url[1]
    background = new Image()

    div = $(@draggableCoverSelector).get(0)
    background.src = image_url
    background.onload = ->
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
    background.onload()

    @height = bgH;
    @width = bgW;

  @saveReposition: =>
    @exitDragging()
#    @pixelsToPercents()
    @initialPosition = $(@draggableCoverSelector).css('background-position')
    @sendRequest(@initialPosition)

  @revertReposition: =>
    $(@draggableCoverSelector).css('background-position', @initialPosition)

  @showButtons: ->
    $(@dragMenuSelector).show()

  @hideButtons: ->
    $(@dragMenuSelector).hide()

  @exitDragging: ->
    @dragging = false
    @hideButtons()
    $(@draggableCoverSelector).backgroundDraggable('disable');
    $(@dragLabelSelector).text(I18n.cover_dragging.start_dragging)

  @pixelsToPercents: ->
    backgroundPosition = $(@draggableCoverSelector).css('background-position')
    displacement = backgroundPosition.split(' ')
    yFloat = parseFloat(displacement[1])
    xFloat = parseFloat(displacement[0])
    y = -(yFloat/(@height + $(@draggableCoverSelector).height()))*100
    x = -(xFloat/(@width))*100
    $(@draggableCoverSelector).css('background-position', "#{ x }% #{ y }%")

  @percentsToPixels: ->
    backgroundPosition = $(@draggableCoverSelector).css('background-position')
    displacement = backgroundPosition.split(' ')
    yPercents = parseFloat(displacement[1])
    xPercents = parseFloat(displacement[0])
    y = -yPercents/100*(@height + $(@draggableCoverSelector).height() + 400)
    x = -xPercents/100*(@width)
    $(@draggableCoverSelector).css('background-position', "#{ x }px #{ y }px")

  @sendRequest: (@initialPosition)=>
    $.ajax(
      data: { portfolio: { cover_position: @initialPosition } }
      url: '/designer_center/portfolio'
      type: 'PATCH'
      dataType: 'json'
      success: (data)=>
        console.log 'saved'
    )

$ ->
  Portfolio.init()
  CoverDragging.init()
  PicturesZoom.initGallery(enlargeButtonSelector: '.portfolio_example a.enlarge', galleryName: 'portfolio')

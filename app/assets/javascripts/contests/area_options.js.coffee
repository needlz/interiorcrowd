class @DesignArea

  constructor: (@parentAreas, @childrenAreas, @areas, @currentIdInput)->

  init: ->
    @hideAllChildrenAreas()
    if @parentSelectionHasChildren()
      @showChildrenButtons()

    @bindRoomButtons()

  bindRoomButtons: ->
    @parentAreas.click((event)=>
      event.preventDefault()
      $button = $(event.target).closest(@parentAreas)
      return if @selectedParentId() is parseInt($button.data('id'))
      @parentAreas.removeClass('active').find('.option-selected').hide()
      $button.addClass('active').find('.option-selected').show()

      @currentIdInput.val($button.data('id'))
      @update()
    )

    @childrenAreas.find('.children').click (event)=>
      @childrenAreas.find('.option-item').removeClass('active')
      $button = $(event.target)
      $button.addClass('active')
      @currentIdInput.val($button.data('id'))

  update: ->
    $("#err_design_area").html('')
    @hideAllChildrenAreas()
    if @parentSelectionHasChildren()
      @currentIdInput.val('')
      @showChildrenButtons()

  id: ->
    parseInt(@currentIdInput.val())

  selectedParentId: ->
    parseInt(@parentAreas.filter('.active').data('id'))

  parentSelectionHasChildren: ->
    $.grep(@areas, (area)=>
      return (area.id == @selectedParentId()) && (area.children.length)
    ).length

  showChildrenButtons: ->
    id = @selectedParentId()
    $children = @childrenAreas.filter("[data-id='#{ id }']")
    $children.animate(opacity: 'show', 200)
    $children.find('.menu-room').show()
    $lastInRow = @parentAreas.filter("[data-id='#{ id }']").parents('.areas-row').nextAll('.last-in-row').first()
    $children.insertAfter($lastInRow)

  hideAllChildrenAreas: ->
    @childrenAreas.hide()

class @RoomsEditor

  @init: ->
    designArea = new DesignArea($('.bedr .room-selector-sub'), $('.menu-room.row'), areas, $('[name="design_brief[design_area]"]'))
    designArea.init()

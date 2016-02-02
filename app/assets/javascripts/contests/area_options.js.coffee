class @DesignArea

  constructor: (@parentAreas, @childrenAreas, @areas)->

  init: ->
    @hideAllChildrenAreas()
    if @parentSelectionHasChildren()
      @showChildrenButtons()

    @bindRoomButtons()
    @childrenAreas.find('input[type=checkbox]').change =>
      @update()
    @update()

  bindRoomButtons: ->
    @parentAreas.click((event)=>
      $button = $(event.target).closest(@parentAreas)
      return if @selectedParentId() is parseInt($button.data('id'))
      $childrenRooms = @childrenAreas.filter("[data-id='#{ $button.attr('data-id') }']")
      hasChildren = $childrenRooms.length
      @parentAreas.removeClass('active')
      $button.addClass('active') if hasChildren
      @update()
    )

    @childrenAreas.find('.children').click (event)=>
      $button = $(event.target)
      $button.toggleClass('active', $($button.attr('for')).is(':checked'))

  update: ->
    @parentAreas.each (index, element)=>
      $parentRoom = $(element)
      $childrenRooms = @childrenAreas.filter("[data-id='#{ $parentRoom.attr('data-id') }']")
      console.log $childrenRooms.find('input[type=checkbox]:checked').length
      $parentRoom.toggleClass('withSelectedChildren', !!$childrenRooms.find('input[type=checkbox]:checked').length)
    $("#err_design_area").html('')
    @hideAllChildrenAreas()
    if @parentSelectionHasChildren()
      @showChildrenButtons()

  selectedParentId: ->
    parseInt(@parentAreas.filter('.active').data('id'))

  parentSelectionHasChildren: ->
    $.grep(@areas, (area)=>
      return (area.id == @selectedParentId()) && (area.children.length)
    ).length

  showChildrenButtons: ->
    id = @selectedParentId()
    $children = @childrenAreas.filter("[data-id='#{ id }']")
    @hideAllChildrenAreas()
    $children.insertAfter(@lastRoomInRow(id))
    $children.animate(opacity: 'show', 200)
    $children.find('.menu-room').show()

  lastRoomInRow: (id)->
    $roomButtons = $('.rooms .areas-row')
    buttonsInRow = 0
    $roomButtons.each ->
      if $(@).prevAll('.areas-row').length > 0
        if $(@).position().top != $(@).prevAll('.areas-row').first().position().top
          return false
        buttonsInRow++
      else
        buttonsInRow++
    buttonRowIndex = Math.ceil(($roomButtons.find("[data-id='#{ id }']").parents('.areas-row').index('.areas-row') + 1) / buttonsInRow)
    lastButtonInRowIndex = buttonRowIndex * buttonsInRow
    $lastRoomButtonInRow = $roomButtons.eq(lastButtonInRowIndex - 1)
    if $lastRoomButtonInRow.length
      $lastRoomButtonInRow.first()
    else
      $roomButtons.find("[data-id='#{ id }']").parents('.areas-row')

  hideAllChildrenAreas: ->
    @childrenAreas.hide()

class @RoomsEditor

  @init: ->
    designArea = new DesignArea($('.bedr .room-selector-sub'), $('.menu-room.row'), areas)
    designArea.init()

class @DesignArea

  constructor: (@parentDropdown, @childrenDropdowns, @areas)->

  init: ->
    @update()
    @parentDropdown.change(=>
      @update()
    )

  update: ->
    $("#err_design_area").html('')
    @hideAllChildrenDropdowns()
    if @selectionHasChildren()
      @parentDropdown.removeAttr('name')
      @showChildrenDropdown()
    else
      @parentDropdown.attr('name', 'design_brief[design_area]')

  id: ->
    parseInt(@parentDropdown.val())

  selectionHasChildren: ->
    $.grep(@areas, (area)=>
      return (area.id == @id()) && (area.children.length)
    ).length

  showChildrenDropdown: ->
    console.log('@childrenDropdowns')
    @childrenDropdowns.filter("[data-id='#{ @id() }']").show().attr('name', 'design_brief[design_area]')

  hideAllChildrenDropdowns: ->
    @childrenDropdowns.hide().removeAttr('name')
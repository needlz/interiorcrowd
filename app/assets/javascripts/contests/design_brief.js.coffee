$(document).ready ->
  designArea = new DesignArea($('#design_area'), $('.area-children'), areas)
  designArea.init()

  $(".order").click (e) ->
    $('.text-error').html('')
    valid = true
    if $(".design_element:checked").length < 1
      $("#err_category").html noCategoryMessage
      valid = false
    if isNaN(parseInt($('select[name="design_area"]').val()))
      $("#err_design_area").html 'Please select one'
      valid = false
    if valid
      e.preventDefault()
      $("#design_categories").submit()


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
      @parentDropdown.attr('name', 'design_area')

  id: ->
    parseInt(@parentDropdown.val())

  selectionHasChildren: ->
    $.grep(@areas, (area)=>
      return (area.id == @id()) && (area.children.length)
    ).length

  showChildrenDropdown: ->
    @childrenDropdowns.filter("[data-id='#{ @id() }']").show().attr('name', 'design_area')

  hideAllChildrenDropdowns: ->
    @childrenDropdowns.hide().removeAttr('name')
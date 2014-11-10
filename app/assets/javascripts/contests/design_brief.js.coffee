$(document).ready ->
  $(".order").click (e) ->
    $("#err_category").html ""
    if $(".design_element:checked").length > 0
      e.preventDefault()
      $("#design_categories").submit()
    else
      $("#err_category").html noCategoryMessage
      false

  designArea = new DesignArea($('#design_area'), $('.area-children'), areas)
  designArea.init()

class @DesignArea

  constructor: (@parentDropdown, @childrenDropdowns, @areas)->

  init: ->
    @update()
    @parentDropdown.change(=>
      @update()
    )

  update: ->
    val = parseInt(@parentDropdown.val())
    @childrenDropdowns.hide().removeAttr('name')
    if $.grep(@areas, (area)->
      return (area.id == val) && (area.children.length)
    ).length
      @childrenDropdowns.filter("[data-id='#{val}']").show().attr('name', 'design_area')
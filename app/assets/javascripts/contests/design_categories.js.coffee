$(document).ready ->
  $(".order").click (e) ->
    $("#err_category").html ""
    if $(".design_element:checked").length > 0
      e.preventDefault()
      $("#design_categories").submit()
    else
      $("#err_category").html "Please select atleast one category."
      false

  updateAreas = (select)->
    val = parseInt(select.val())
    $('.area-children').hide().removeAttr('name')
    if $.grep(areas, (area)->
      return (area.id == val) && (area.children.length)
    ).length
      $(".area-children[data-id='#{val}']").show().attr('name', 'design_area')

  updateAreas($('#design_area'))

  $('#design_area').change ->
    updateAreas($(@))
$(document).ready ->
  designArea = new DesignArea($('.bedr .room-selector-sub'), $('.menu-room.row'), areas, $('[name="design_brief[design_area]"]'))
  designArea.init()

  $('.btn1-confirm').click (e) ->
    $('.text-error').html('')
    errors = []
    if $(".design_element:checked").length < 1
      errors.push($("#err_category").html I18n.errors.select_category)
    if isNaN(parseInt($('[name="design_brief[design_area]"]').val()))
      errors.push($("#err_design_area").html I18n.errors.select_room)

    if errors.length
      errors[0].get(0).scrollIntoView()
    else
      e.preventDefault()
      $("#design_categories").submit()

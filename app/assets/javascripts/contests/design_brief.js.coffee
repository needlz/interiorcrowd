$(document).ready ->
  designArea = new DesignArea($('.bedr .room-selector'), $('.menu-room.row'), areas, $('[name="design_brief[design_area]"]'))
  designArea.init()

  $('.btn-confirm').click (e) ->
    $('.text-error').html('')
    errors = []
    if $(".design_element:checked").length < 1
      errors.push($("#err_category").html I18n.creation.errors.select_category)
    if isNaN(parseInt($('[name="design_brief[design_area]"]').val()))
      errors.push($("#err_design_area").html 'Please select one')

    if errors.length
      errors[0].get(0).scrollIntoView()
    else
      e.preventDefault()
      $("#design_categories").submit()

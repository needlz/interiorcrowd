$(document).ready ->
  designArea = new DesignArea($('#design_area'), $('.area-children'), areas)
  designArea.init()

  $(".order").click (e) ->
    $('.text-error').html('')
    valid = true
    if $(".design_element:checked").length < 1
      $("#err_category").html noCategoryMessage
      valid = false
    if isNaN(parseInt($('select[name="design_brief[design_area]"]').val()))
      $("#err_design_area").html 'Please select one'
      valid = false
    if valid
      e.preventDefault()
      $("#design_categories").submit()

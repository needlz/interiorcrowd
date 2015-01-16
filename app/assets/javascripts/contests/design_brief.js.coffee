$(document).ready ->
  RoomsEditor.init()

  $('.btn1-confirm').click (e) ->
    $('.text-error').html('')
    incompleteForms = []
    if $(".design_element:checked").length < 1
      $("#err_category").html I18n.errors.select_category
      incompleteForms.push($('.packages'))
    selectedRoomId = parseInt($('[name="design_brief[design_area]"]').val())
    if isNaN(selectedRoomId)
      $("#err_design_area").html I18n.errors.select_room
      incompleteForms.push($('.rooms'))
    if incompleteForms.length
      incompleteForms[0].get(0).scrollIntoView()
    else
      e.preventDefault()
      $("#design_categories").submit()

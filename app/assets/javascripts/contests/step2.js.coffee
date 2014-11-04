$(document).ready ->
  $(".continue").click (e) ->
    $("#err_area").html ""
    if $(".design_space:checked").length > 0
      e.preventDefault()
      $("#step2").submit()
    else
      $("#err_area").html "Please select atleast one area."
      false

  $(".design_space").click (e) ->
    parent_id = $(this).attr("parent_id")
    $("#" + parent_id).attr "checked", "'checked'"  if parent_id > 0

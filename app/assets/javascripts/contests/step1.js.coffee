$(document).ready ->
  $(".order").click (e) ->
    $("#err_category").html ""
    if $(".design_element:checked").length > 0
      e.preventDefault()
      $("#step1").submit()
    else
      $("#err_category").html "Please select atleast one category."
      false

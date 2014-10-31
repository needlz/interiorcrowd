jQuery(document).ready ->
  jQuery(".continue").click (e) ->
    jQuery("#err_area").html ""
    if jQuery(".design_space:checked").length > 0
      e.preventDefault()
      jQuery("#step2").submit()
    else
      jQuery("#err_area").html "Please select atleast one area."
      false

  jQuery(".design_space").click (e) ->
    parent_id = jQuery(this).attr("parent_id")
    jQuery("#" + parent_id).attr "checked", "'checked'"  if parent_id > 0

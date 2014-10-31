jQuery(document).ready ->
  jQuery(".order").click (e) ->
    jQuery("#err_category").html ""
    if jQuery(".design_element:checked").length > 0
      e.preventDefault()
      jQuery("#step1").submit()
    else
      jQuery("#err_category").html "Please select atleast one category."
      false
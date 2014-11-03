jQuery ->
  jQuery(".home_wrapper").click (e) ->
    jQuery(".home_wrapper").removeClass "alert-info"
    jQuery(this).addClass "alert-info"
    jQuery("#plan_id").val jQuery(this).attr("plan_id")

  plan_id = jQuery("#plan_id").val()
  jQuery("#" + plan_id).addClass "alert-info"  if plan_id.length > 0
  jQuery(".continue").click (e) ->
    e.preventDefault()
    jQuery(".text-error").html ""
    pname = jQuery.trim(jQuery("#project_name").val())
    pbudget = jQuery.trim(jQuery("#plan_id").val())
    bool = true
    focus = false
    if pname.length < 1
      bool = false
      jQuery("#err_prj_name").html "Please enter project_name."
      focus = "project_name"
    if pbudget.length < 1
      bool = false
      jQuery("#err_plan").html "Please choose plan."
      focus = "err_plan"  unless focus
    if bool
      jQuery("#step6").submit()
    else
      jQuery("#" + focus).focus()
      false
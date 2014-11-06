$ ->
  $(".home_wrapper").click (e) ->
    $(".home_wrapper").removeClass "alert-info"
    $(this).addClass "alert-info"
    $("#plan_id").val $(this).attr("plan_id")

  plan_id = $("#plan_id").val()
  $("#" + plan_id).addClass "alert-info"  if plan_id.length > 0
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    pname = $.trim($("#project_name").val())
    pbudget = $.trim($("#plan_id").val())
    bool = true
    focus = false
    if pname.length < 1
      bool = false
      $("#err_prj_name").html "Please enter project_name."
      focus = "project_name"
    if pbudget.length < 1
      bool = false
      $("#err_plan").html "Please choose plan."
      focus = "err_plan"  unless focus
    if bool
      $("#account_creation").submit()
    else
      $("#" + focus).focus()
      false
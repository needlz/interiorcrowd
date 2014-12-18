$ ->
  $('.plan').click (event) ->
    $('.plan-container').removeClass('active')
    $plan = $(event.target).parents('.plan-container')
    $plan.addClass('active')
    $('#plan_id').val($plan.find('[plan_id]').attr('plan_id'))

  plan_id = $('#plan_id').val()
  $('#' + plan_id).addClass 'active' if plan_id.length > 0
  $('.continue').click (e) ->
    e.preventDefault()
    $('.text-error').html ''
    pname = $.trim($('#project_name').val())
    pbudget = $.trim($('#plan_id').val())
    bool = true
    focus = false
    if pname.length < 1
      bool = false
      $('#err_prj_name').html I18n.name_error
      focus = 'project_name'
    if pbudget.length < 1
      bool = false
      $('#err_plan').html I18n.plan_error
      focus = 'err_plan' unless focus
    if bool
      $('#account_creation').submit()
    else
      $('#' + focus).focus()
      false

  ContestPreview.init()

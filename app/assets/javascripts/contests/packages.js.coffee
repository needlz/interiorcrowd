class @Packages

  @init: ->
    @initActivePlan()
    @bindPlansBoxes()

  @initActivePlan: ->
    plan_id = $('#plan_id').val()
    $('#' + plan_id).addClass 'active' if plan_id.length > 0

  @bindPlansBoxes: ->
    $('.plan').click (event) ->
      $('.plan-container').removeClass('active')
      $plan = $(event.target).parents('.plan-container')
      $plan.addClass('active')
      $('#plan_id').val($plan.data('id'))

  @selectedPackage: ->
    $.trim($('#plan_id').val())

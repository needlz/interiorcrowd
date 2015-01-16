class ReviewPage

  @init: ->
    @initActivePlan()
    @bindPlansBoxes()
    @bindContinueButton()
    @validator = new ValidationMessages()

  @initActivePlan: ->
    plan_id = $('#plan_id').val()
    $('#' + plan_id).addClass 'active' if plan_id.length > 0

  @bindPlansBoxes: ->
    $('.plan').click (event) ->
      $('.plan-container').removeClass('active')
      $plan = $(event.target).parents('.plan-container')
      $plan.addClass('active')
      $('#plan_id').val($plan.data('id'))

  @bindContinueButton: ->
    $('.continue').click (e) =>
      e.preventDefault()
      @validate()
      if @validator.valid
        $('#account_creation').submit()
      else
        @validator.focusOnMessage()
        false

  @validate: ->
    @validator.reset()
    $('.text-error').text('')

    pname = $.trim($('#project_name').val())
    if pname.length < 1
      @validator.addMessage $('#err_prj_name'), I18n.name_error, $('#project_name')

    pbudget = $.trim($('#plan_id').val())
    if pbudget.length < 1
      @validator.addMessage $('#err_plan'), I18n.plan_error, $('.packages-description')

$ ->
  ReviewPage.init()

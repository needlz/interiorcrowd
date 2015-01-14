class Validations

  @reset: ->
    @clearErrors()
    @valid = true
    @validationMessage = null
    @elementToFocus = null

  @validate: (errorCondition, $validationMessage, text, elementToFocus)->
    if errorCondition
      @valid = false
      $validationMessage.text(text)
      @elementToFocus = @elementToFocus || elementToFocus

  @clearErrors: ->
    $('.text-error').text('')

class ReviewPage

  @init: ->
    @bindPlansBoxes()
    @initActivePlan()
    @bindContinueButton()

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
      pname = $.trim($('#project_name').val())
      pbudget = $.trim($('#plan_id').val())
      Validations.reset()
      Validations.validate(pname.length < 1, $('#err_prj_name'), I18n.name_error, '#project_name')
      Validations.validate(pbudget.length < 1, $('#err_plan'), I18n.plan_error, '.plans')
      if Validations.valid
        $('#account_creation').submit()
      else
        $(Validations.elementToFocus).focus()
        false



$ ->
  ReviewPage.init()

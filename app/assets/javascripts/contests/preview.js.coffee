class Validator

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
    @initActivePlan()
    @bindPlansBoxes()
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
      @validate()
      if Validator.valid
        $('#account_creation').submit()
      else
        $(Validator.elementToFocus).focus()
        false

  @validate: ->
    pname = $.trim($('#project_name').val())
    pbudget = $.trim($('#plan_id').val())
    Validator.reset()
    Validator.validate(pname.length < 1, $('#err_prj_name'), I18n.name_error, '#project_name')
    Validator.validate(pbudget.length < 1, $('#err_plan'), I18n.plan_error, '.plans')

$ ->
  ReviewPage.init()

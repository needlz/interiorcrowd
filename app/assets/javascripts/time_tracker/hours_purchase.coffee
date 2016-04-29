class @HoursPurchase

  minValue = 0
  maxValue = 99
  defaultValue = 0
  hoursSubmit = '.hours-submit'
  suggestHours = '#suggest-hours'
  inputSelector = '.tracker-hours-panel input'
  designerSuggestedHoursSelector = '.tracker-sent-hours'
  designerSuggestedHoursAmountSelector = '.tracker-sent-hours span'
  addActivityButtonSelector = '.add-activity-button button'
  activityFormCancelButtonSelector = '.designer-activity-form-cancel-button'
  activityDescriptionSelector = '.activity-description'
  addActivityFormSelector = '.designer-activity-form'

  @init: ->
    bindMinusButton()
    bindPlusButton()
    bindInputValidation()
    bindInputScrolling()
    bindInputPasteBlocking()
    bindHoursSuggestedInput()
    bindDesignerSuggestedHoursDisplay()
    bindSuggestingButton()
    bindDisplayAddActivityForm()

  bindMinusButton = ->
    $('#minus-hour').click =>
      decreaseHoursAmount()

  bindPlusButton = ->
    $('#plus-hour').click =>
      increaseHoursAmount()

  bindInputValidation = ->
    bindStepperPlugin()
    bindSeparatorInputBlocking()
    bindSettingToDefaultValue()

  bindStepperPlugin = ->
    $(inputSelector).jStepper({
      minValue: minValue,
      maxValue: maxValue,
      disableAutocomplete: true,
      defaultValue: defaultValue,
      allowDecimals: false,
      overflowMode: 'ignore'
    })

  bindSeparatorInputBlocking = ->
    $(inputSelector).keydown (key) ->
      return false if (key.which == 110) || (key.which == 173) || (key.which == 188) || (key.which == 190)

  bindInputPasteBlocking = ->
    $(document).ready ->
      $(inputSelector).bind 'paste', ->
        return false

  bindSettingToDefaultValue = ->
    $(inputSelector).focusout ->
      $(inputSelector).val(defaultValue) unless $(inputSelector).val()
      $(inputSelector).change()

  bindHoursSuggestedInput = ->
    $(document).on 'change keyup', inputSelector, ->
      toggleButtonDisabling()

  bindSuggestingButton = ->
    $(suggestHours).on 'click', ->
      sendSuggestRequest()

  bindDesignerSuggestedHoursDisplay = ->
    $(designerSuggestedHoursSelector).show() if (suggestedHours() > 0)

  decreaseHoursAmount = ->
    oldValue = parseInt($(inputSelector).val())
    $(inputSelector).val(oldValue - 1) if (oldValue > minValue)
    $(inputSelector).change()

  increaseHoursAmount = ->
    oldValue = parseInt($(inputSelector).val())
    $(inputSelector).val(oldValue + 1) if (oldValue < maxValue)
    $(inputSelector).change()

  bindInputScrolling = ->
    $(inputSelector).bind 'mousewheel', ->
      $(inputSelector).change()

  bindDisplayAddActivityForm = ->
    $(addActivityButtonSelector). on 'click', ->
      $(activityDescriptionSelector).hide()
      $(addActivityFormSelector).show()
    $(activityFormCancelButtonSelector).on 'click', ->
      $(addActivityFormSelector).hide()
      $(activityDescriptionSelector).show()

  sendSuggestRequest = ->
    $.ajax(
      data: {suggested_hours: parseInt($(inputSelector).val())}
      url: $(suggestHours).attr('url')
      type: 'POST'
      success: (response) =>
        updateSuggestedHours(parseInt(response))
      error: (response)->
        console.log('Server error while trying to suggest hours: ' + response.responseText)
    )

  toggleButtonDisabling = ->
    unless ((parseInt($(inputSelector).val()) == 0) || ($(inputSelector).val() == ''))
      $(hoursSubmit).attr('disabled', false)
    else
      $(hoursSubmit).attr('disabled', true)

  updateSuggestedHours = (suggestedHours)->
    $(designerSuggestedHoursAmountSelector).text(suggestedHours)
    $(inputSelector).val(defaultValue)
    $(inputSelector).change();
    $(designerSuggestedHoursSelector).show()

  suggestedHours = ->
    return parseInt($(designerSuggestedHoursAmountSelector).text())

$ ->
  HoursPurchase.init()


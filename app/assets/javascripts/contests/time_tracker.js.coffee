class TimeTracker
  minValue = 0
  maxValue = 99
  defaultValue = 0
  inputSelector = '.tracker-hours-panel input'
  suggestHours = '#suggest-hours'

  bindEvents: ->
    bindMinusButton()
    bindPlusButton()
    bindInputValidation()

  bindMinusButton = ->
    $('#minus-hour').click =>
      oldValue = parseInt($(inputSelector).val())
      $(inputSelector).val(oldValue - 1) if (oldValue > minValue)
      $(inputSelector).change();

  bindPlusButton = ->
    $('#plus-hour').click =>
      oldValue = parseInt($(inputSelector).val())
      $(inputSelector).val(oldValue + 1) if (oldValue < maxValue)
      $(inputSelector).change();

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

  bindSettingToDefaultValue = ->
    $(inputSelector).focusout ->
      $(inputSelector).val(defaultValue) unless $(inputSelector).val()
      $(inputSelector).change();

$ ->
  tracker = new TimeTracker()
  tracker.bindEvents()


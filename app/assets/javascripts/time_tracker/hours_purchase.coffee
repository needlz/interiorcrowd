class @HoursPurchase

  minValue = 0
  maxValue = 99
  defaultValue = 0
  hoursSubmit = '.hours-submit'
  suggestHours = '#suggest-hours'
  inputSelector = '.tracker-hours-panel input'
  designerSuggestedHoursSelector = '.tracker-sent-hours'
  designerSuggestedHoursAmountSelector = '.tracker-sent-hours span'

  @init: ->
    bindMinusButton()
    bindPlusButton()
    bindInputValidation()
    bindInputScrolling()
    bindInputPasteBlocking()
    bindHoursSuggestedInput()
    bindDesignerSuggestedHoursDisplay()
    bindSuggestingButton()

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

class @ActivityEditor
  addActivityButtonSelector = '.add-activity-button button'
  activityFormCancelButtonSelector = '.designer-activity-form-cancel-button'
  activityDescriptionSelector = '.activity-description'
  addActivityFormSelector = '.designer-activity-form'
  submitButtonSelector = '.designer-activity-form-submit-button'
  newActivityCommentSelector = '.new_designer_activity_comment'
  activityHeaderSelector = '.activities .activity .collapse'

  @init: ->
    bindDisplayAddActivityForm()
    $(document).on 'ajax:success', addActivityFormSelector, onSubmitted
    $(document).on 'ajax:success', newActivityCommentSelector, onCommentSubmitted
    $(document).on 'shown.bs.collapse', activityHeaderSelector, onCommentUncollapsed
    activityForm().find('#designer_activity_hours').ForceNumericOnly()

    activityForm().find('#designer_activity_start_date').datepicker(
      defaultDate: "+1w",
      changeMonth: true,
      onClose: (selectedDate)->
        activityForm().find('#designer_activity_due_date').datepicker( "option", "minDate", selectedDate )
    )
    activityForm().find('#designer_activity_due_date').datepicker(
      defaultDate: "+1w",
      changeMonth: true,
      onClose: (selectedDate)->
        activityForm().find('#designer_activity_start_date').datepicker( "option", "maxDate", selectedDate )
    )

  onCommentUncollapsed = (event)->
    $target = $(event.target)
    $unreadCommentsIcon = $target.closest('.activity[data-id]').find('.commentsIcon.withComments')
    if $unreadCommentsIcon.length
      url = $target.attr('data-read-url')
      $.ajax(
        data: { method: 'patch' }
        url: url
        type: 'PATCH'
        success: (response) =>
          console.log response
          if response.saved
            activities().find(".activity[data-id=#{ response.activity_id }] .commentsIcon").removeClass('withComments')
        error: (response)->
          console.log('Server error while trying to mark comment as read')
      )

  onSubmitted = (event, response)->
    addActivity(response)

  onCommentSubmitted = (event, response)->
    $commentForm = $(event.target)
    $activity = $commentForm.closest('.activity')
    $activity.replaceWith(response.new_activity_html)

  addActivity = (response)->
    activityDescription().hide()
    activitiesHeader().show()
    $group = activities().find(".group[data-id=#{ response.date_range_id }]")
    unless $group.length
      later_activities = activities().find('.group').filter ->
        $(@).attr('data-id') > response.date_range_id
      if later_activities.length
        later_activities.last().after(response.date_range_header_html)
      else
        activities().prepend(response.date_range_header_html)
      $group = activities().find(".group[data-id=#{ response.date_range_id }]")
    $group.find('.group-activities').append(response.new_activity_html)
    closeActivityForm()

  activitiesHeader = ->
    $('.activitiesHeader')

  addActivityButton = ->
    $(addActivityButtonSelector)

  cancelActivityButton = ->
    $(activityFormCancelButtonSelector)

  activityDescription = ->
    $(activityDescriptionSelector)

  activityForm = ->
    $(addActivityFormSelector)

  bindDisplayAddActivityForm = ->
    addActivityButton().click ->
      if activityForm().is(':visible')
        closeActivityForm()
      else
        activityDescription().hide()
        activityForm().show()
    cancelActivityButton().click ->
      closeActivityForm()

  closeActivityForm = ->
    activityForm().hide()
    activityDescription().show() if noActivities()

  noActivities = ->
    activities().find('.activity[data-id]').length < 1

  activities = ->
    $('.activities')

$ ->
  HoursPurchase.init()
  ActivityEditor.init()

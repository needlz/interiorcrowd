class @ActivityEditor
  addActivityButtonSelector = '.add-activity-button button'
  activityFormCancelButtonSelector = '.designer-activity-form-cancel-button'
  activityDescriptionSelector = '.activity-description'
  addActivityFormSelector = '.designer-activity-form'
  submitButtonSelector = '.designer-activity-form-submit-button'
  newActivityCommentSelector = '.new_designer_activity_comment'
  activityHeaderSelector = '.activities .activity .collapse'

  @init: ->
    @bindActivityFormSwitcher()
    $(document).on 'ajax:success', addActivityFormSelector, onSubmitted
    $(document).on 'ajax:success', newActivityCommentSelector, onCommentSubmitted
    $(document).on 'shown.bs.collapse', activityHeaderSelector, onCommentUncollapsed
    activityForm().find('#designer_activity_hours').ForceNumericOnly()
    @setupDatePickers()
    @bindNewTaskButton()
    closeActivityForm()


  @setupDatePickers: ->
    activityForm().find('#designer_activity_start_date').datetimepicker(
      format: 'MM/DD/YYYY'
    ).on("dp.change", (e)->
      activityForm().find('#designer_activity_due_date').data("DateTimePicker").minDate(e.date);
    )
    activityForm().find('#designer_activity_due_date').datetimepicker(
      format: 'MM/DD/YYYY'
      useCurrent: false
    ).on("dp.change", (e)->
      activityForm().find('#designer_activity_start_date').data("DateTimePicker").maxDate(e.date);
    )

  @bindNewTaskButton: ->
    $('.designer-activity-form .designer-activity-form-add-more-button').click addTaskForm

  addTaskForm = (event)->
    $form = activityForm()

    newId = new Date().getTime()
    regexp = new RegExp("new_item", "g")
    $newTask = $('<div>').append($form.find('.task.template').clone())
    $newTask = $($newTask.html().replace(regexp, newId))
    $newTask.removeClass('template')

    $form.find('.tasks').append($newTask)

  onCommentUncollapsed = (event)->
    $target = $(event.target)
    $unreadCommentsIcon = $target.closest('.activity[data-id]').find('.commentsIcon.withComments')
    if $unreadCommentsIcon.length
      url = $target.attr('data-read-url')
      markCommentsAsRead(url)

  markCommentsAsRead = (url)->
    $.ajax(
      data: { method: 'patch' }
      url: url
      type: 'PATCH'
      success: (response) =>
        if response.saved
          activities().find(".activity[data-id=#{ response.activity_id }] .commentsIcon").removeClass('withComments')
      error: (response)->
        console.log('Server error while trying to mark comment as read')
    )

  onSubmitted = (event, response)->
    addActivities(response)

  onCommentSubmitted = (event, response)->
    $commentForm = $(event.target)
    $activity = $commentForm.closest('.activity')
    $activity.replaceWith(response.new_activity_html)

  addActivities = (response)->
    activityDescription().hide()
    activitiesHeader().show()

    updateActivities(response.activities)
    updateGroupTitles(response.groups_titles_html)

  updateActivities = (activitiesJson)->
    noErrors = true
    clearErrorMessages()
    for activity in activitiesJson
      $task = activityForm().find(".task[data-temporary-id=#{ activity.temporary_id }]")
      if activity.error
        noErrors = false
        handleValidationError($task, activity.error)
      else
        updateActivity($task, activity)
    closeActivityForm() if noErrors

  handleValidationError = ($task, errorJosn)->
    for field, messages of errorJosn
      $task.find('.error-row').filter(".#{ field }").removeClass('hidden').text(messages.join('; '))
      activityForm().find('.error-row').filter(".#{ field }").removeClass('hidden').text(messages.join('; '))

  updateActivity = ($task, activityJson)->
    $group = activities().find(".group[data-id=#{ activityJson.group_id }]")
    unless $group.length
      later_activities = activities().find('.group').filter ->
        $(@).attr('data-id') > activityJson.group_id
      if later_activities.length
        later_activities.last().after(activityJson.group_header_html)
      else
        activities().prepend(activityJson.group_header_html)
      $group = groupById(activityJson.group_id)
    $group.find('.group-activities').append(activityJson.new_activity_html)
    $group.find('> .collapse').collapse('show')

    $task.remove()

  updateGroupTitles = (groupTitlesJson)->
    for group_title in groupTitlesJson
      $group = groupById(group_title.group_id)
      $group.find('> .title').html(group_title.title_html)

  groupById = (id)->
    activities().find(".group[data-id=#{ id }]")

  clearActivityForm = ->
    activityForm().find('.task[data-temporary-id]:not(.template)').remove()
    addTaskForm()

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

  @bindActivityFormSwitcher: ->
    addActivityButton().click ->
      if activityForm().is(':visible')
        closeActivityForm()
      else
        activityDescription().hide()
        activityForm().show()
    cancelActivityButton().click ->
      closeActivityForm()
      removeBlankTasks()
      addTaskForm() unless activityForm().find('.task[data-temporary-id]:not(.template)').length

  removeBlankTasks = ->
    tasks = activityForm().find('.task[data-temporary-id]:not(.template)')
    for task in tasks
      keepTask = false
      $task  = $(task)
      for formGroup in $task.find('.form-group')
        $formGroup = $(formGroup)
        input = $formGroup.find('input, textarea')
        keepTask = (input.val() != input.attr('data-default-value'))
      $task.remove() unless keepTask

  closeActivityForm = ->
    activityForm().hide()
    activityDescription().show() if noActivities()
    clearErrorMessages()

  noActivities = ->
    activities().find('.activity[data-id]').length < 1

  activities = ->
    $('.activities')

  clearErrorMessages = ->
    activityForm().find('.error-row').addClass('hidden')

$ ->
  ActivityEditor.init()

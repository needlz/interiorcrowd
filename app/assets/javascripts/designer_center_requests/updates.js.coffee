class @Notifications

  @buttons = '.updates-notifications .btn'
  @notifications = '.updates-notifications .notification'
  @notificationPadding = 62

  @init: () ->
    @.initButtons()
    @filterNotificationTypes()
    @resizeNotifications()

  @resizeNotifications: ->
    height = null
    $('.leftBorderNotification').each (i, border)=>
      $border = $(border)
      height = "#{ $border.parent().find('.designerNotification').height() + @notificationPadding }px"
      $border.css 'height', height

  @initButtons: ->
    $(@buttons).on 'click', (event)=>
      $button = $(event.target)
      @filterNotificationTypes($button.attr('type'))
      @.reverseColor($button)

  @filterNotificationTypes: (notificationsType)->
    @.hideAllNotifications();
    @.show(notificationsType)

  @hideAllNotifications: ->
    $(@notifications).hide()

  @show: (notificationsType) =>
    notificationsFilter = if notificationsType then "[type=#{ notificationsType }]" else '*'
    $(@notifications).filter(notificationsFilter).show()

  @reverseColor: ($btn) ->
    $(@buttons).removeAttr('reverse')
    $btn.attr('reverse', true)

$ ->
  Notifications.init()

  $('#scrollBoxComments').enscroll
    verticalTrackClass: 'scrollBoxCommentsTrack'
    verticalHandleClass: 'scrollBoxCommentsHandle'
    minScrollbarLength: 28

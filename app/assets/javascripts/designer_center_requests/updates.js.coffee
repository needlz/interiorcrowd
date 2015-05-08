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
      type = $button.attr('type')
      mixpanel.track('Designer: updates filtered', { type: type })
      @filterNotificationTypes(type)
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

class Comments

  @beautifyScroll: ->
    $('#scrollBoxComments').enscroll
      verticalTrackClass: 'scrollBoxCommentsTrack'
      verticalHandleClass: 'scrollBoxCommentsHandle'
      minScrollbarLength: 28

$ ->
  Notifications.init()
  Comments.beautifyScroll()
  $(window).resize ->
    Notifications.resizeNotifications()

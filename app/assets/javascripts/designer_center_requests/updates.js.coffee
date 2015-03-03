class @Notifications

  @buttons = '.updates-notifications .btn'
  @notifications = '.updates-notifications .notification'

  @init: () ->
    @.initButtons()
    @filterNotificationTypes()

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

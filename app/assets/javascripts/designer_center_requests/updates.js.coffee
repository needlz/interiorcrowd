class @Notifications

  @buttons = '.updates-notifications .btn'
  @notificationsContainer = '.updates-notifications'

  @init: (type) ->
    @.initButtons()
    @.hideAllNotifications()
    @.show(type)

  @initButtons: ->
    $(@buttons).on 'click', (event)=>
      $button = $(event.target)
      notificationsTypes = $button.attr('type').split(',')
      @filterNotificationTypes(notificationsTypes)
      @.reverseColor($button)

  @filterNotificationTypes: (notificationsTypes)->
    @.hideAllNotifications();
    @.show(notificationsTypes)

  @hideAllNotifications: ->
    $(@notificationsContainer).find('.notification').hide()

  @show: (notificationsTypes) =>
    for type in notificationsTypes
      if type
        $(@notificationsContainer).find(".notification[type=#{ type }]").show()
      else
        $(@notificationsContainer).find(".notification").show()

  @reverseColor: ($btn) ->
    $(@buttons).removeAttr('reverse')
    $btn.attr('reverse', true)

$ ->
  Notifications.init([''])

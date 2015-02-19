class @Notifications

  @buttons = '.updates-notifications .btn'

  @init: (type) ->
    @.initButtons()
    @.hideAllNotifications()
    @.show(type)

  @initButtons: ->
    $(@buttons).on 'click', =>
      @.hideAllNotifications();
      @.show($(event.target).attr('type'))
      @.reverseColor(event.target)

  @hideAllNotifications: ->
    $('.notification').hide()

  @show: (color) ->
    $(".notification[type=#{color}]").show()

  @reverseColor: (btn) ->
    $(@buttons).removeAttr('reverse')
    $(btn).attr('reverse', true)

$ ->
  Notifications.init('invite')


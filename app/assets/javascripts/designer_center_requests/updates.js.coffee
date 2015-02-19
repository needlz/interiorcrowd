class @Notifications

  @buttons = '.updates-notifications .btn'

  @init: (type) ->
    @.initButtons()
    @.hideAllNotifications()
    @.show(type)

  @initButtons: ->
    self = @
    $(@buttons).on 'click', ->
      self.hideAllNotifications();
      self.show($(@).attr('type'))
      self.reverseColor(@)

  @hideAllNotifications: ->
    $('.notification').hide()

  @show: (color) ->
    $(".notification[type=#{color}]").show()

  @reverseColor: (btn) ->
    $(@buttons).removeAttr('reverse')
    $(btn).attr('reverse', true)

$ ->
  Notifications.init('invite')


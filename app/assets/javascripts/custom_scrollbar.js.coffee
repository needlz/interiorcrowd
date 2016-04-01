$.fn.customScrollBar = (options)->
  options ||= {}
  options.scrollInertia = 200 # scrolling momentum as animation duration in milliseconds
  options.theme = 'icrowd' # prefix of used css styles
  @.mCustomScrollbar(options)

$.fn.removeCustomScrollBar = ()->
  @.mCustomScrollbar("destroy")

$.fn.customScrollBarScrollBottom = ()->
  @.mCustomScrollbar("scrollTo", "bottom", {
    scrollInertia: 400
  })

class Buttons
  @buttons =  '.contest-buttons .btn'

  @init: ->
    $(@buttons).on 'click', (event)=>
      @.reverseColor(event.target)

  @reverseColor: (btn) ->
    $(@buttons).removeAttr('reverse')
    $(btn).attr('reverse', true)

$ ->
  Buttons.init()

  $('h3.seeCompletedContests').click ->
    $('#completedContestsBox').toggleClass 'show'

  $('h3.seeCurrentContests').click ->
    $('#currentContestsBox').toggleClass 'show'

class Buttons
  @buttons =  '.contest-buttons .btn'

  @init: ->
    $(@buttons).on 'click', (event)=>
      @.reverseColor(event.target)

  @reverseColor: (btn) ->
    $(@buttons).removeAttr('reverse')
    $(btn).attr('reverse', true)

class ResponsesList

  @makeTableRowsClickable: ->
    $('.row.contestTableRow1').click (event)->
      $row = $(event.target).closest('.row.contestTableRow1')
      document.location = "/designer_center/contests/#{ $row.data('id') }"

$ ->
  ResponsesList.makeTableRowsClickable()
  Buttons.init()

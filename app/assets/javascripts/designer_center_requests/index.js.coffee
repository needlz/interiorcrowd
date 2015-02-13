class ResponsesList

  @makeTableRowsClickable: ->
    $('.row.contestTableRow1').click (event)->
      $row = $(event.target).closest('.row.contestTableRow1')
      document.location = "/designer_center/contests/#{ $row.data('id') }"

$ ->
  ResponsesList.makeTableRowsClickable()

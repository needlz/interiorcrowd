class @ContestsList
  makeTableRowsClickable: ->
    $('.contest-item').click (event)->
      $row = $(event.target).parents('.contest-item')
      document.location = "/contests/#{ $row.data('id') }"

$ ->
  contestsList = new ContestsList()
  contestsList.makeTableRowsClickable()
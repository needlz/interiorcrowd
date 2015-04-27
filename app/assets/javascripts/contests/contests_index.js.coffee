class @ContestsList
  makeTableRowsClickable: ->
    $('.contest-item').click (event)->
      $row = $(event.target).parents('.contest-item')
      url = "/designer_center/contests/#{ $row.data('id') }"
      mixpanel.track 'Link clicked', { url: url, link_name: 'Available contest' }
      setTimeout(
        ->
          document.location = url
        , 300)

$ ->
  contestsList = new ContestsList()
  contestsList.makeTableRowsClickable()

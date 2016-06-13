$ ->
  $(location.hash).collapse('show')
  panelId = $(location.hash).closest('[role="tabpanel"]').attr('id')
  $("a[href='##{ panelId }']").tab('show')
$ ->
  $('a[data-collapse="true"]').on 'click', (e) ->
    anchorId = $(e.target).attr('href')
    $(anchorId).collapse('show')

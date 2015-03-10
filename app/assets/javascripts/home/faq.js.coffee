$ ->
  $(location.hash).collapse('show');
  panelId = $(location.hash).closest('[role="tabpanel"]').attr('id')
  $("a[href='##{ panelId }']").tab('show');

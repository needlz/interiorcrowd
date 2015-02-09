$ ->
  $(location.hash).collapse('show');
  panelId = $(location.hash).parents('[role="tabpanel"]').attr('id')
  $("a[href='##{ panelId }']").tab('show');

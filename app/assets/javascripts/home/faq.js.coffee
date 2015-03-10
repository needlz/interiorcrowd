$ ->
  $(location.hash).collapse('show');
  panelId = $(location.hash).parents('[role="tabpanel"]').attr('id')
  panelId = $(location.hash).filter('[role="tabpanel"]').attr('id') unless panelId
  $("a[href='##{ panelId }']").tab('show');

$ ->
  $('.pull-down').each ->
    $(@).css('margin-top', $(@).parent().height() - $(@).height())

$ ->
  mixpanel.track_forms '#design_space', 'Pictures & dimensions updated', (form)->
    $form = $(form)
    { data: $form.serializeArray() }

  DesignSpaceOptions.init()

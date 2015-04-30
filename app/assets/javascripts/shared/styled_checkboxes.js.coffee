class @StyledCheckboxes

  @init: (options)->
    styledCheckboxSelector = options.styledCheckboxSelector
    switchOnClick = !options.inLabel
    $(styledCheckboxSelector).each ->
      $button = $(@)
      $checkbox = $button.parent().find(':checkbox')
      $button.toggleClass('active', $checkbox.is(':checked'))

    if switchOnClick
      $(styledCheckboxSelector).click ->
        $(@).closest(styledCheckboxSelector).toggleClass 'active'
        $checkbox = $(@).parent().find(':checkbox')
        $checkbox.prop('checked', $(@).closest(styledCheckboxSelector).hasClass('active'))
        $checkbox.change()

    $('.hidden:checkbox').change (event)->
      $checkbox = $(@)
      $checkbox.parent().find(styledCheckboxSelector).toggleClass('active', $checkbox.is(':checked'))

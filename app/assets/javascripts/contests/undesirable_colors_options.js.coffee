class @UndesirableColorsEditor

  @init: ->
    undesirableColorsEditor = new ColorsEditor
      $colorTags: $('#refrain_color')
      $colorsTable: $('.avoided-colors .colors-table')
      $colorInput: $('.avoided-colors .color-name')
    undesirableColorsEditor.init()

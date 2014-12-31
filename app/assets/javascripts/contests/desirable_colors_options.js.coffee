class @DesirableColorsEditor

  @init: ->
    desirableColorsEditor = new ColorsEditor
      $colorTags: $('#fav_color')
      $colorsTable: $('.fav-colors .colors-table')
      $colorInput: $('.fav-colors .color-name')
    desirableColorsEditor.init()

class Validations

  constructor: (@appealsCount, @levelContainer)->

  init: ()->
    allAppealsSelected = ->
      $('.likes input:checked').length == @appealsCount

    $(".slidercon input").slider()
    $(".continue").click (e) =>
      e.preventDefault()
      $(".text-error").html ""
      fav_color = $.trim($("#fav_color").val())
      refrain_color = $.trim($("#refrain_color").val())
      valid = true
      if fav_color.length < 1
        valid = false
        $("#err_fav").html I18n.validations.no_colors
      if refrain_color.length < 1
        valid = false
        $("#err_refrain").html I18n.validations.no_colors
      if isNaN(parseInt(@levelContainer.val()))
        valid = false
        $("#err-designer-level").html I18n.validations.select_design_level
      unless allAppealsSelected()
        valid = false
        $("#err-appeals").html I18n.validations.no_appeals
      if valid
        $("#design_style").submit()
      else
        false

$ ->
  $levelContainer = $("input[name='design_style[designer_level]']")
  validations = new Validations(appealsCount, $levelContainer)
  validations.init()
  ExamplesUploader.init()

  DesirableColorsEditor.init()
  UndesirableColorsEditor.init()

  AppealsForm.init()

  inspirationLinksEditor = new InspirationLinksEditor()
  inspirationLinksEditor.init()

  $('.level-block').click ->
    $selectedLevel = $(@)
    newId = $selectedLevel.data('id')
    $levelContainer.val(newId)

    $('.level-block').removeClass('active')
    $('.level-block').find('.check').hide()
    $selectedLevel.addClass('active')
    $selectedLevel.find('.check').show()

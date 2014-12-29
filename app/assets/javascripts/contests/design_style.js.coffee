class Validations

  constructor: (@appealsCount)->

  init: ()->
    $levelContainer = $("input[name='design_style[designer_level]']")

    allAppealsSelected = ->
      $('.likes input:checked').length == @appealsCount

    $(".slidercon input").slider()
    $(".continue").click (e) ->
      e.preventDefault()
      $(".text-error").html ""
      fav_color = $.trim($("#fav_color").val())
      refrain_color = $.trim($("#refrain_color").val())
      valid = true
      if fav_color.length < 1
        valid = false
        $("#err_fav").html "Please enter data."
      if refrain_color.length < 1
        valid = false
        $("#err_refrain").html "Please enter data."
      if isNaN(parseInt($levelContainer.val()))
        valid = false
        $("#err-designer-level").html "Please select one"
      unless allAppealsSelected()
        valid = false
        $("#err-appeals").html "Please pick your opinion for each appeal"
      if valid
        $("#design_style").submit()
      else
        false

$ ->
  validations = new Validations(appealsCount)
  validations.init()
  ExamplesUploader.init()
  DesirableColorsEditor.init()
  UndesirableColorsEditor.init()
  AppealsForm.init()

  $('.level-block').click ->
    $selectedLevel = $(@)
    newId = $selectedLevel.data('id')
    $levelContainer.val(newId)

    $('.level-block').removeClass('active')
    $('.level-block').find('.check').hide()
    $selectedLevel.addClass('active')
    $selectedLevel.find('.check').show()

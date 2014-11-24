$ ->
  levelContainer = $("input[name='design_style[designer_level]']")

  allAppealsSelected = ->
    $.grep($('select.appeal'), (appeal)->
      $(appeal).val() == ''
    ).length == 0


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
    if isNaN(parseInt(levelContainer.val()))
      valid = false
      $("#err-designer-level").html "Please select one"
    unless allAppealsSelected()
      valid = false
      $("#err-appeals").html "Please pick your opinion for each appeal"
    if valid
      $("#design_style").submit()
    else
      false

  ExamplesUploader.init()
  DesirableColorsEditor.init()
  UndesirableColorsEditor.init()

  $('.level-block').click ->
    selectedLevel = $(@)
    newId = selectedLevel.attr('data-id')
    levelContainer.val(newId)

    $('.level-block').removeClass('active')
    selectedLevel.addClass('active')

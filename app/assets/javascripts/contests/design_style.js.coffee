$ ->
  levelContainer = $("input[name='design_style[designer_level]']")

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
      $("#err-designer-level").html "Please select one of the options."
    if valid
      $("#design_style").submit()
    else
      false

  $("#file_input").initUploader
    buttonText: "Upload"
    removeTimeout: 5
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_val = $.trim($("#design_style_imge").val())
      img_id = $.trim($("#design_style_image_id").val())
      if img_val.length < 1
        $("#design_style_image").val info[0]
        $("#design_style_image_id").val info[1]
      else
        $("#design_style_image").val img_val + "," + info[0]
        $("#design_style_image_id").val img_id + "," + info[1]

  $('.level-block').click ->
    selectedLevel = $(@)
    newId = selectedLevel.attr('data-id')
    levelContainer.val(newId)

    $('.level-block').removeClass('active')
    selectedLevel.addClass('active')

  $('.color-typeahead').colorTags({ readonly: false })

$ ->
  $(".slidercon input").slider()
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    fav_color = $.trim($("#fav_color").val())
    refrain_color = $.trim($("#refrain_color").val())
    bool = true
    if fav_color.length < 1
      bool = false
      $("#err_fav").html "Please enter data."
    if refrain_color.length < 1
      bool = false
      $("#err_refrain").html "Please enter data."
    if bool
      $("#design_style").submit()
    else
      false

$ ->
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

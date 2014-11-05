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
      $("#step3").submit()
    else
      false

$ ->
  $("#file_input").initUploader
    buttonText: "Upload"
    removeTimeout: 5
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_val = $.trim($("#step3_imge").val())
      img_id = $.trim($("#step3_image_id").val())
      if img_val.length < 1
        $("#step3_image").val info[0]
        $("#step3_image_id").val info[1]
      else
        $("#step3_image").val img_val + "," + info[0]
        $("#step3_image_id").val img_id + "," + info[1]

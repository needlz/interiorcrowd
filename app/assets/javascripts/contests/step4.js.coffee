$ ->
  $(".continue").click (e) ->
    e.preventDefault()
    $(".text-error").html ""
    f_length = $.trim($("#length_feet").val())
    i_length = $.trim($("#length_inches").val())
    f_width = $.trim($("#width_feet").val())
    i_width = $.trim($("#width_inches").val())
    bool = true
    focus = false
    if f_length.length < 1 and i_length.length < 1
      bool = false
      $("#err_length").html "Please enter length."
      focus = "length_feet"
    if f_width.length < 1 and i_width < 1
      bool = false
      $("#err_width").html "Please enter width."
      focus = "width_feet"  unless focus
    if bool
      $("#step4").submit()
    else
      $("#" + focus).focus()
      false

$ ->
  $("#file_input").uploadify
    uploader: uploadifyUploader
    swf: "/uploadify.swf"
    buttonText: "Upload"
    fileSizeLimit: uploadifyFileSizeLimit
    fileTypeExts: "*.png;*.jpg;*.tif"
    uploadLimit: 3
    fileObjName: "photo"
    multi: false
    auto: true
    removeTimeout: 10
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_val = $.trim($("#step4_image").val())
      img_id = $.trim($("#step4_image_id").val())
      if img_val.length < 1
        $("#step4_image").val info[0]
        $("#step4_image_id").val info[1]
      else
        $("#step4_image").val img_val + "," + info[0]
        $("#step4_image_id").val img_id + "," + info[1]
    formData: uploadifyFormData
    cancelImg: "/images/cancel.png" #take care that the image is accessible

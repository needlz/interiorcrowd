jQuery ->
  jQuery(".continue").click (e) ->
    e.preventDefault()
    jQuery(".text-error").html ""
    f_length = jQuery.trim(jQuery("#f_length").val())
    i_length = jQuery.trim(jQuery("#i_length").val())
    f_width = jQuery.trim(jQuery("#f_width").val())
    i_width = jQuery.trim(jQuery("#i_width").val())
    bool = true
    focus = false
    if f_length.length < 1 and i_length.length < 1
      bool = false
      jQuery("#err_length").html "Please enter length."
      focus = "f_length"
    if f_width.length < 1 and i_width < 1
      bool = false
      jQuery("#err_width").html "Please enter width."
      focus = "f_width"  unless focus
    if bool
      jQuery("#step4").submit()
    else
      jQuery("#" + focus).focus()
      false

jQuery ->
  jQuery("#file_input").uploadify
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

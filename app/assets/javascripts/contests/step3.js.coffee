jQuery ->
  jQuery(".slidercon input").slider()
  jQuery(".continue").click (e) ->
    e.preventDefault()
    jQuery(".text-error").html ""
    fav_color = jQuery.trim(jQuery("#fav_color").val())
    refrain_color = jQuery.trim(jQuery("#refrain_color").val())
    bool = true
    if fav_color.length < 1
      bool = false
      jQuery("#err_fav").html "Please enter data."
    if refrain_color.length < 1
      bool = false
      jQuery("#err_refrain").html "Please enter data."
    if bool
      jQuery("#step3").submit()
    else
      false

jQuery ->
  # encode the session into a Flash-save format
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
    formData: uploadifyFormData
    cancelImg: "/images/cancel.png" #take care that the image is accessible

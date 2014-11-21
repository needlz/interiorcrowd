class @ExamplesUploader

  @init: ->
    $(".example-pictures #file_input").initUploader
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

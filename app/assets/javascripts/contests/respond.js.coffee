jQuery ->
  jQuery(".continue").click (e) ->
    jQuery("#new_contest_request").submit()

  jQuery("#file_input").uploadify
    uploader: uploadifyUploader
    swf: "/uploadify.swf"
    buttonText: "Upload a design"
    fileSizeLimit: uploadifyFileSizeLimit
    fileTypeExts: "*.png;*.jpg;*.tif"
    uploadLimit: 3
    fileObjName: "photo"
    multi: false
    auto: true
    removeTimeout: 3
    onUploadSuccess: (file, data, response) ->
      info = data.split(",")
      $("#image_display").append "<img src='" + info[0] + "' />"
      img_id = $.trim($("#contest_request_designs").val())
      if img_id.length < 1
        $("#contest_request_designs").val info[1]
      else
        $("#contest_request_designs").val img_id + "," + info[1]


  #alert('The file ' + file.name + ' was successfully uploaded.');
    formData: uploadifyFormData
    cancelImg: "/images/cancel.png" #take care that the image is accessible
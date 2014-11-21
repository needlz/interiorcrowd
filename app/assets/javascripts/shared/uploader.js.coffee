$.fn.initUploader = (uploadifyOptions) ->
  @.uploadify
    uploader: uploadifyUploader
    swf: '/uploadify.swf'
    buttonText: uploadifyOptions.buttonText
    fileSizeLimit: uploadifyFileSizeLimit
    fileTypeExts: '*.png;*.jpg;*.tif'
    uploadLimit: uploadifyOptions.uploadLimit || 3
    fileObjName: 'photo'
    multi: false
    auto: true
    removeTimeout: uploadifyOptions.removeTimeout
    onUploadSuccess: uploadifyOptions.onUploadSuccess
    formData: uploadifyFormData
    cancelImg: '/images/cancel.png' #take care that the image is accessible

$.fn.initUploaderWithThumbs = (thumbSelector, uploadifyOptions) ->
  @.initUploader(
    $.extend(
      onUploadSuccess: (file, data, response) ->
        info = data.split(",")
        $("#image_display").append "<img src='" + info[0] + "' />"
        img_val = $.trim($(thumbSelector).val())
        img_id = $.trim($(thumbSelector + '_id').val())
        if img_val.length < 1
          $(thumbSelector).val info[0]
          $(thumbSelector + '_id').val info[1]
        else
          $(thumbSelector).val img_val + "," + info[0]
          $(thumbSelector + '_id').val img_id + "," + info[1]
      uploadifyOptions
    )
  )

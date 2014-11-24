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

$.fn.initUploaderWithThumbs = (options) ->
  @.initUploader(
    $.extend(
      onUploadSuccess: (file, data, response) ->
        info = data.split(",")
        imageUrl = info[0]
        imageId = info[1]
        $(options.thumbs.container).append "<img src='#{ imageUrl }' />"
        $imageIds = $(options.thumbs.selector)
        previousIds = if $imageIds.val().length then $imageIds.val() + ',' else ''
        $imageIds.val(previousIds + imageId)
      options.uploadify
    )
  )

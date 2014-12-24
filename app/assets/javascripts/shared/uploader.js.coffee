$.fn.initUploader = (uploadifyOptions) ->
  @.uploadify
    uploader: uploadifyUploader
    swf: '/uploadify.swf'
    buttonText: uploadifyOptions.buttonText
    fileSizeLimit: uploadifyFileSizeLimit
    fileTypeExts: '*.png;*.jpg;*.tif'
    uploadLimit: uploadifyOptions.uploadLimit
    fileObjName: 'photo'
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
        $imageIds = $(options.thumbs.selector)
        if options.single
          $img = $(options.thumbs.container).find('img')
          $img = $('<img>').appendTo($(options.thumbs.container)) unless $img.length
          $img.attr('src', imageUrl)
          $imageIds.val(imageId)
        else
          $(options.thumbs.container).append "<img src='#{ imageUrl }' />"
          previousIds = ''
          previousIds = $imageIds.val() + ',' if $imageIds.val().length
          $imageIds.val(previousIds + imageId)
      options.uploadify
    )
    $.extend(options.uploadify, { multi: false }) if options.single
  )

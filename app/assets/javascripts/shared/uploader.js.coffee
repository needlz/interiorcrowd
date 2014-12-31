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
          $container = $('<div class="col-md-3 novice">')
          $img = $(options.thumbs.container).find('.col-md-3.novice img')
          $img = $('<img>') unless $img.length
          $closeButton = $('<a href="#">')
          $closeButton.append($('<i class="circle3 glyphicon glyphicon-remove pull-right glyphic-round">'))
          $img.attr('src', imageUrl)

          $container.append($img)
          $container.append($closeButton)
          $imageIds.val(imageId)
        else
          $container = $('<div class="col-md-3 novice">')
          $container.append $("<img src='#{ imageUrl }' />")
          $closeButton = $('<a href="#">')
          $closeButton.append($('<i class="circle3 glyphicon glyphicon-remove pull-right glyphic-round">'))
          $container.append $closeButton
          $(options.thumbs.container).append $container
          previousIds = ''
          previousIds = $imageIds.val() + ',' if $imageIds.val().length
          $imageIds.val(previousIds + imageId)
      options.uploadify
    )
    $.extend(options.uploadify, { multi: false }) if options.single
  )

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
  thumbsTheme = if options.thumbs.theme is 'new' then RemovableThumbsTheme else DefaultThumbsTheme
  $imageIds = $(options.thumbs.selector)
  $container = $(options.thumbs.container)
  if thumbsTheme is RemovableThumbsTheme
    $container.on 'click', '.remove-thumb-button', $imageIds, RemovableThumbsTheme.removeThumb

  @.initUploader(
    $.extend(
      onUploadSuccess: (file, data, response) ->
        info = data.split(",")
        imageUrl = info[0]
        imageId = info[1]
        if options.single
          thumbsTheme.thumbForSingleImageUploader(imageUrl, imageId, $container, $imageIds)
          $imageIds.val(imageId)
        else
          thumbsTheme.thumbForMultipleImageUploader(imageUrl, imageId, $container, $imageIds)
          previousIds = ''
          previousIds = $imageIds.val() + ',' if $imageIds.val().length
          $imageIds.val(previousIds + imageId)
      options.uploadify
    )
    $.extend(options.uploadify, { multi: false }) if options.single
  )

class DefaultThumbsTheme

  @thumbForSingleImageUploader: (imageUrl, imageId, $thumbsContainer, $imageIds) ->
    $img = $thumbsContainer.find('img')
    $img = $('<img>').appendTo($thumbsContainer) unless $img.length
    $img.attr('src', imageUrl)

  @thumbForMultipleImageUploader: (imageUrl, imageId, $thumbsContainer, $imageIds) ->
    $thumbsContainer.append "<img src='#{ imageUrl }' />"

class RemovableThumbsTheme

  @removeThumb: (event)->
    $thumbContainer = $(event.target).parents('.thumb')
    $imageIds = event.data
    imageIds = $imageIds.val().split(',')
    imageId = $thumbContainer.data('id')
    indexOfThumb = imageIds.indexOf(imageId)
    imageIds.splice(indexOfThumb, 1)
    $imageIds.val(imageIds.join(','))
    $thumbContainer.remove()
    event.preventDefault()

  @thumbForMultipleImageUploader: (imageUrl, imageId, $thumbsContainer, $imageIds) ->
    $template = $thumbsContainer.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', imageId)
    $container.find('img').attr('src', imageUrl)
    $thumbsContainer.append $container

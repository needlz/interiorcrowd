$.fn.initUploader = (uploadifyOptions)->
  @.fileupload uploadifyOptions


$.fn.initUploaderWithThumbs = (options) ->
  $imageIds = $(options.thumbs.selector)
  $container = $(options.thumbs.container)
  thumbsTheme = if options.thumbs.theme is 'new'
      new RemovableThumbsTheme($container, $imageIds)
    else
      new DefaultThumbsTheme($container, $imageIds)
  thumbsTheme.init()

  @.initUploader(
    $.extend(
      dataType: 'json'
      url: uploadifyUploader
      done: (e, data) ->
        $.each data.result.files, (index, file) ->
          imageUrl = file.url
          imageId = file.id
          if options.single
            thumbsTheme.thumbForSingleImageUploader(imageUrl, imageId)
            $imageIds.val(imageId)
          else
            thumbsTheme.thumbForMultipleImageUploader(imageUrl, imageId)
            previousIds = ''
            previousIds = $imageIds.val() + ',' if $imageIds.val().length
            $imageIds.val(previousIds + imageId)
      options.uploadify
    )
  )

class ThumbsTheme

  constructor: (@$container, @$imageIds)->

  init: ->

class DefaultThumbsTheme extends ThumbsTheme

  thumbForSingleImageUploader: (imageUrl, imageId) ->
    $img = @$container.find('img')
    $img = $('<img>').appendTo(@$container) unless $img.length
    $img.attr('src', imageUrl)

  thumbForMultipleImageUploader: (imageUrl, imageId) ->
    @$container.append "<img src='#{ imageUrl }' />"

class RemovableThumbsTheme extends ThumbsTheme

  init: ->
    @$container.on 'click', '.remove-thumb-button', @removeThumb

  removeThumb: (event)=>
    event.preventDefault()
    $thumbContainer = $(event.target).parents('.thumb')
    imageIds = @$imageIds.val().split(',')
    imageId = $thumbContainer.data('id')
    indexOfThumb = imageIds.indexOf(imageId)
    imageIds.splice(indexOfThumb, 1)
    @$imageIds.val(imageIds.join(','))
    $thumbContainer.remove()

  thumbForMultipleImageUploader: (imageUrl, imageId) ->
    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', imageId)
    $container.find('img').attr('src', imageUrl)
    @$container.append $container

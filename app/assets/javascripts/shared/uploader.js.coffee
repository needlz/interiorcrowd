$.fn.initUploader = (options)->
  $.extend(
    options,
    dataType: 'json'
    url: uploadifyUploader
    type: 'POST'
  )
  @.fileupload
    add: (event, data)=>
        # script uses native form of input by default, that causes side effects
      $inputWithoutForm = $(@).clone()
      $inputWithoutForm.fileupload(options)
      $inputWithoutForm.fileupload('add', { files: data.files })

$.fn.initUploaderWithThumbs = (options) ->
  uploader = new Uploader($(@), options)
  uploader.init()

class Uploader

  constructor: (@$input, @options)->

  init: ()->
    @$container = $(@options.thumbs.container)
    @$imageIds = $(@options.thumbs.selector)
    @thumbsTheme = if @options.thumbs.theme is 'new'
        new RemovableThumbsTheme(@$container, @$imageIds)
      else
        new DefaultThumbsTheme(@$container, @$imageIds)
    @thumbsTheme.init()

    @bindUploadScript()

  bindUploadScript: ->
    uploadOptions = {}
    $.extend(
      uploadOptions
      done: @onUploaded
      @options.uploadify
    )

    @$input.initUploader(uploadOptions)

  onUploaded: (event, data) =>
    $.each data.result.files, (index, file) =>
      imageUrl = file.url
      imageId = file.id
      if @options.single
        @thumbsTheme.thumbForSingleImageUploader(imageUrl, imageId)
        @$imageIds.val(imageId)
      else
        @thumbsTheme.thumbForMultipleImageUploader(imageUrl, imageId)
        previousIds = ''
        previousIds = @$imageIds.val() + ',' if @$imageIds.val().length
        @$imageIds.val(previousIds + imageId)

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

  thumbForSingleImageUploader: (imageUrl, imageId) ->
    $img = @$container.find('img')
    if $img.length
      $img.attr('src', imageUrl)
    else
      $template = @$container.find('.template')
      $thumb = $template.clone()
      @$container.append $thumb

  thumbForMultipleImageUploader: (imageUrl, imageId) ->
    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', imageId)
    $container.find('img').attr('src', imageUrl)
    @$container.append $container

  createThumb: (imageId)

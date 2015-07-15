$.fn.initUploader = (options)->
  $.extend(
    options,
    dataType: 'json'
    url: uploadifyUploader
    type: 'POST'
  )
  @.fileupload
    replaceFileInput: false
    add: (event, data)=>
      # by default, script uses native form of input by default, this causes side effects
      $inputWithoutForm = $(@).clone()
      $inputWithoutForm.fileupload(options)
      $inputWithoutForm.fileupload('add', { files: data.files })
      $(@).val('')

$.fn.initUploaderWithThumbs = (options) ->
  uploader = new Uploader($(@), options)
  uploader.init()
  uploader

class Uploader

  constructor: (@$input, @options)->

  init: ()->
    @$container = $(@options.thumbs.container)
    @$imageIds = $(@options.thumbs.selector)
    themeClass = @options.thumbs.theme || DefaultThumbsTheme
    @thumbsTheme = new themeClass(@$container, @$imageIds)
    @thumbsTheme.onRemoved = @options.thumbs.onRemoved
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
        previousIds = @$imageIds.val() + ',' if @$imageIds.val()
        @$imageIds.val(previousIds + imageId)

class @ThumbsTheme

  constructor: (@$container, @$imageIds)->

  init: ->

class @DefaultThumbsTheme extends ThumbsTheme

  thumbForSingleImageUploader: (imageUrl, imageId) ->
    $img = @$container.find('img')
    $img = $('<img>').appendTo(@$container) unless $img.length
    $img.attr('src', imageUrl)

  thumbForMultipleImageUploader: (imageUrl, imageId) ->
    @$container.append "<img src='#{ imageUrl }' />"

class @DivContainerThumbsTheme extends ThumbsTheme

  thumbForSingleImageUploader: (imageUrl, imageId) ->
    $img = @$container.find('.image-container')
    $img.css('background-image', "url('#{ encodeURI(imageUrl) }')")

class @RemovableThumbsTheme extends ThumbsTheme

  init: ->
    @$container.on 'click', '.remove-thumb-button', @removeThumb

  removeThumb: (event)=>
    event.preventDefault()
    $thumbContainer = $(event.target).parents('.thumb')
    @remove($thumbContainer)

  getImageId: ($thumb)->
    $thumb.data('id')

  remove: ($thumbContainer)->
    $thumbContainer.each (i, element)=>
      $thumb = $(element)
      imageIds = @$imageIds.val().split(',') if @$imageIds.val()
      imageId = @getImageId($thumb)
      if imageId && imageIds
        indexOfThumb = imageIds.indexOf(imageId.toString())
        imageIds.splice(indexOfThumb, 1)
        @$imageIds.val(imageIds.join(','))
      $thumb.remove()
      @onRemoved?(imageId)

  thumbForSingleImageUploader: (imageUrl, imageId) ->
    $img = @$container.find('.thumb img:first')
    if $img.length
      $img.attr('src', imageUrl)
    else
      $template = @$container.find('.template')
      $thumb = @createThumb(imageUrl, imageId)
      @insertThumb($thumb)

  thumbForMultipleImageUploader: (imageUrl, imageId) ->
    $thumb = @createThumb(imageUrl, imageId)
    @insertThumb($thumb)

  createThumb: (imageUrl, imageId)->
    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', imageId)
    $container.find('img:first').attr('src', imageUrl)
    $container

  insertThumb: (thumb) ->
    @$container.append(thumb)

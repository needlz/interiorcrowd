$(document).bind('drop dragover', (e)->
  e.preventDefault()
)

$.fn.initUploader = (options)->
  $inputWithoutForm = @.clone()
  $.extend(
    options,
    dataType: 'json'
    url: uploadifyUploader
    type: 'POST'
    formData: (form)->
      []
    replaceFileInput: false # the plugin recreates the input element after each upload, and so events bound to the original input will be lost.
  )
  @.fileupload(options)
  @.val('')

$.fn.initUploaderWithThumbs = (options) ->
  uploader = new Uploader($(@), options)
  uploader.init()
  uploader

class Uploader

  constructor: (@$input, @options)->

  init: ()->
    @$container = $(@options.thumbs.container)
    @$imageIds = $(@options.thumbs.selector)
    themeClass = @options.thumbs.theme
    if themeClass
      @thumbsTheme = new themeClass(@$container, @$imageIds)
      @thumbsTheme.onRemoved = @options.thumbs.onRemoved
      @thumbsTheme.init()

    @bindUploadScript()

  bindUploadScript: ->
    uploadOptions = {}
    $.extend(
      uploadOptions
      {
        done: @onUploaded
        dropZone: @options.thumbs.dropZone || null
        fileInput: @options.fileInput
      }
      @options.uploadify
    )

    @$input.initUploader(uploadOptions)

  onUploaded: (event, data) =>
    $.each data.result.files, (index, file) =>
      imageUrl = file.url
      imageId = file.id
      if @options.single
        @onSingleFileUploaded(imageUrl, imageId)
      else
        @onMultipleFilesUploaded(imageUrl, imageId)

  onSingleFileUploaded: (imageUrl, imageId)->
    if @thumbsTheme
      @thumbsTheme.thumbForSingleImageUploader(imageUrl, imageId)
    @$imageIds.val(imageId)

  onMultipleFilesUploaded: (imageUrl, imageId)->
    if @thumbsTheme
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

window.humanFileSize = (bytes, si) ->
  thresh = if si then 1000 else 1024
  if Math.abs(bytes) < thresh
    return bytes + ' B'
  units = if si then [
    'kB'
    'MB'
    'GB'
    'TB'
    'PB'
    'EB'
    'ZB'
    'YB'
  ] else [
    'KiB'
    'MiB'
    'GiB'
    'TiB'
    'PiB'
    'EiB'
    'ZiB'
    'YiB'
  ]
  u = -1
  loop
    bytes /= thresh
    ++u
    unless Math.abs(bytes) >= thresh and u < units.length - 1
      break
  bytes.toFixed(1) + ' ' + units[u]

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
        progress: @onProgress
        submit: @onSend
        processalways: @onProcessalways

      }
      @options.uploadify
    )

    @$input.initUploader(uploadOptions)

  onUploaded: (event, data) =>
    $.each data.result.files, (index, fileInfo) =>
      if @options.single
        @onSingleFileUploaded(fileInfo)
      else
        @onMultipleFilesUploaded(fileInfo)
    @options.uploadify.onUploaded?(data.result) if @options.uploadify

  onProgress: (event, data)=>
    progress = parseInt(data.loaded / data.total * 100, 10);
    file = data.files[0]
    @thumbsTheme.onProgress?(file, progress) if @thumbsTheme

  onSingleFileUploaded: (fileInfo)->
    @thumbsTheme.thumbForSingleImageUploader(fileInfo) if @thumbsTheme
    @$imageIds.val(fileInfo.id)

  onMultipleFilesUploaded: (fileInfo)->
    @thumbsTheme.thumbForMultipleImageUploader(fileInfo) if @thumbsTheme
    previousIds = ''
    previousIds = @$imageIds.val() + ',' if @$imageIds.val()
    @$imageIds.val(previousIds + fileInfo.id)

  onSend: (e, data)=>
    file = data.files[0]
    @thumbsTheme.onSend?(file) if @thumbsTheme

  onProcessalways: (e, data)=>
    file = data.files[0]
    @thumbsTheme.onProcessalways?(file) if @thumbsTheme

class @ThumbsTheme

  constructor: (@$container, @$imageIds)->

  init: ->

class @DefaultThumbsTheme extends ThumbsTheme

  thumbForSingleImageUploader: (fileInfo) ->
    $img = @$container.find('img')
    $img = $('<img>').appendTo(@$container) unless $img.length
    $img.attr('src', fileInfo.url)

  thumbForMultipleImageUploader: (fileInfo) ->
    @$container.append "<img src='#{ fileInfo.url }' />"

class @DivContainerThumbsTheme extends ThumbsTheme

  thumbForSingleImageUploader: (fileInfo) ->
    $img = @$container.find('.image-container')
    $img.css('background-image', "url('#{ encodeURI(fileInfo.url) }')")

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

  thumbForSingleImageUploader: (fileInfo) ->
    $img = @$container.find('.thumb img:first')
    if $img.length
      $img.attr('src', fileInfo.url)
    else
      $template = @$container.find('.template')
      $thumb = @createThumb(fileInfo)
      @insertThumb($thumb)

  thumbForMultipleImageUploader: (fileInfo) ->
    $thumb = @createThumb(fileInfo)
    @insertThumb($thumb)

  createThumb: (fileInfo)->
    $template = @$container.find('.template')
    $container = $template.clone()
    $container.removeClass('template').addClass('thumb')
    $container.data('id', fileInfo.id)
    $container.find('img:first').attr('src', fileInfo.url)
    $container

  insertThumb: (thumb) ->
    @$container.append(thumb)

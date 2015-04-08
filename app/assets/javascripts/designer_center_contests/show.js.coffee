class DesignerCenterContestBrief

  @init: ->
    ContestPreview.initColorPickers()
    ContestPreview.initStyleCollagesZooming()
    ContestPreview.initStyleDetailsPopups()
    @initExamplesZooming()

  @initExamplesZooming: ->
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=space_pictures] a.enlarge', galleryName: 'space')
    PicturesZoom.initGallery(enlargeButtonSelector: '[data-id=example_pictures] a.enlarge', galleryName: 'examples')


class DownloadAllPhotoButton

  @init: ->
    $('.download-all').click (event)=>
      event.preventDefault()
      return if @processing

      $button = $(event.target).closest('.download-all')
      request_url = "/contests/#{ $button.parents('.contestInfo').data('id') }/download_all_images_url"

      downloadButton = new DownloadAllPhotoButton($button, request_url)
      downloadButton.init()

  constructor: (@$button, @path)->

  init: ->
    @$button.find('.text').text(downloadAllI18n.generating_archive)

    $.ajax(
      data: { type: 'space_pictures' }
      url: @path
      success: (path)=>
        if path.trim().length > 0
          @executeDonwload(path)
        else
          @bindCheckInterval()
    )
    @processing = true

  bindCheckInterval: ->
    @interval = setInterval(=>
      $.ajax(
        data: { type: 'space_pictures' }
        url: url
        success: (path)=>
          @checkArchivationProcess()
      )
    , 3000);

  checkArchivationProcess: =>
    if path.trim().length > 0
      @executeDonwload(path)
      clearInterval(@interval)

  executeDonwload: (path)->
    @processing = false
    @$button.find('.text').text(downloadAllI18n.download_images)
    window.location.href = path


$ ->
  DesignerCenterContestBrief.init()
  DownloadAllPhotoButton.init()

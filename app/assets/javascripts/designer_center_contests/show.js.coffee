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

  @init: (imagesType)->
    $('.download-all').click (event)=>
      event.preventDefault()
      $button = $(event.target).closest('.download-all')

      return if $button.data('download-button')

      request_url = "/contests/#{ $button.parents('.contestInfo').data('id') }/download_all_images_url"
      downloadButton = new DownloadAllPhotoButton($button, request_url, imagesType)
      downloadButton.init()
      $button.data('download-button', downloadButton)

  constructor: (@$button, @path, @imagesType)->

  init: ->
    @$button.find('.text').text(downloadAllI18n.generating_archive)

    @processing = true
    @checkIfDownloaded()

  checkIfDownloaded: =>
    $.ajax(
      data: { type: @imagesType }
      url: @path
      success: (path)=>
        if path.trim().length > 0
          @executeDownload(path)
        else
          setTimeout(@checkIfDownloaded, 1500)
    )

  executeDownload: (path)=>
    @processing = false
    @$button.find('.text').text(downloadAllI18n.download_images)
    window.location.href = path

$ ->
  DesignerCenterContestBrief.init()
  DownloadAllPhotoButton.init('space_images')

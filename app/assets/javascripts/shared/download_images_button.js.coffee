class @DownloadImagesArchive

  @init: (pageI18n)->
    $('.download-all').click (event)=>
      event.preventDefault()
      imagesType = @imagesType()
      $button = $(event.target).closest('.download-all')

      return if $button.data('download-button')

      contestId = @contestId($button)
      mixpanel.track('Download all photo', { contest_id: contestId, images_type: imagesType })
      request_url = "/contests/#{ contestId }/download_all_images_url"
      downloadButton = new @($button, request_url, imagesType, pageI18n)
      downloadButton.init()
      $button.data('download-button', downloadButton)

  constructor: (@$button, @path, @imagesType, @I18n)->

  init: ->
    @textHolder().text(@I18n.generating_archive)

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
    @textHolder().text(@I18n.download_images)
    window.location.href = path

class @DownloadFinalConceptBoards extends DownloadImagesArchive

  @contestId: ->
    $('#contest-data').data('id')

  textHolder: ->
    @$button

  @imagesType: ->
    'concept_board_images'

class @TrackerAttachmentsTheme extends RemovableThumbsTheme

  createThumb: (fileInfo)->
    $container = super
    $container.addClass('col-xs-12')
    $enlargeButton = $container.find('.enlarge')
    $enlargeButton.attr('href', fileInfo.original_size_url)
    $container.find('.downloadButton').attr('href', fileInfo.download_url)
    $container.find('.size').text(humanFileSize(fileInfo.file_size)) if fileInfo.file_size
    $container.find('.filename').text(fileInfo.name)
    PicturesZoom.init($enlargeButton)
    @removeUploadItem(fileInfo.original_name)
    $container

  onProgress: (file, progressPercents)->
    $container = @uploadThumb(file.name)
    $container.find('.progressbar .pointer').width("#{ progressPercents }%")

  addUploadItem: (file)->
    $('.tracker-upload-description').hide()
    $('.tracker-upload').show()
    $template = @$container.find('.uploadingTemplate')
    $container = $template.clone()
    $container.removeClass('uploadingTemplate').addClass('uploadingThumb thumb col-xs-12')
    $container.attr('data-filename', file.name)
    $container.find('.filename').text(file.name)
    fileSize = humanFileSize(file.size, 'si')
    $container.find('.size').text(fileSize)
    @$container.append($container)

  removeUploadItem: (filename)->
    $container = @uploadThumb(filename)
    $container.remove()

  uploadThumb: (filename)->
    @$container.find(".uploadingThumb[data-filename='#{ filename }']")

  onProcess: (file)->
    @addUploadItem(file)

  onProcessDone: (file)->
    canvas = file.preview
    return unless canvas
    dataUrl = canvas.toDataURL()
    @uploadThumb(file.name).find('.preview').attr('src', dataUrl)

  onUploaded: (file)->
    $container = @uploadThumb(file.name)
    $container.find('.progressbar').removeClass('col-xs-4')
    $container.find('.progressbar').remove()
    $container.find('.remove-thumb-button').hide()
    $container.find('.upload-container').removeClass('col-xs-5').addClass('col-xs-6 col-md-5')
    $container.find('.menuButtons').removeClass('col-xs-2').addClass('col-xs-6 col-md-5')
    $container.find('.server-processing').show()

    $container.find('.processing').show()

  onFail: (file)->
    $container = @uploadThumb(file.name)
    $container.find('.progressbar').hide()
    $container.find('.processing').show().text('Uploading error')

  isUploadHalted: (fileInfo)->
    !@uploadThumb(fileInfo.original_name).length

  @onRemoved: ->
    if @filesCount() < 1
      $('.tracker-upload').hide()
      $('.tracker-upload-description').show()

  @filesCount: ()->
    $('.tracker-upload .thumbs .thumb[data-id]').length


class @TrackerAttachmentUploader

  attachmentUrl = ->
    $('.tracker-upload').attr('data-attachment-url')

  removeThumb = (target) ->
    $button = $(target)
    $thumb = $button.closest('.thumb[data-id]')
    $thumb.remove()
    TrackerAttachmentsTheme.onRemoved()

  bindRemoveButton = (button)->
    $('.tracker-upload .thumbs').on 'click', '.thumb .menuButtons ' + button, (event)->
      removeThumb(event.target)

  toggleEnablity = (button) ->
    if (button.attr('style'))
      button.removeAttr('style');
    else
      button.css({"pointer-events": "none", "background":"#81BA98"});

  detectThumbId = (button) ->
    button.closest('.thumb[data-id]').attr('data-id')

  detectMenuButtons = (button) ->
    button.closest('.menuButtons')

  detectSubmittedDate = (button) ->
    button.closest('.thumb').find('.submitted_date')

  changeMenuButtons = (button) ->
    detectMenuButtons(button).find('.file-has-sent').show()
    detectMenuButtons(button).find('.delete').remove()
    detectMenuButtons(button).find('.submit').remove()

  showTimeSubmittedHeader = ->
    if ($('.tracker-upload').find('.submitted_date:not(:empty)').length > 0)
      $('.tracker-upload').find('.timeSubmitted').show()

  showTimeSubmitted = (button, submittedDate) ->
    detectSubmittedDate(button).text(submittedDate).show()

  onSubmitted = (button, submittedDate)->
    showTimeSubmitted(button,submittedDate)
    changeMenuButtons(button)
    showTimeSubmittedHeader()
    toggleEnablity(button)

  sendSubmitRequest = (button) ->
    $.ajax(
      data: { id: detectThumbId(button) }
      url: attachmentUrl()
      type: 'POST'
      beforeSend: =>
        toggleEnablity(button)
      success: (response) =>
        onSubmitted(button, response.submitted_at)
      error: (response)->
        console.log(response)
        toggleEnablity(button)
    )

  bindSubmitButton = ->
    $('.tracker-upload .thumbs').on 'click', '.thumb .menuButtons .submit', (event)->
      sendSubmitRequest($(event.target))

  @bindUploadButton = ($inputsContainer)->
    showTimeSubmittedHeader()
    bindSubmitButton()
    bindRemoveButton('.delete')
    bindRemoveButton('.remove-thumb-button')

    PicturesUploadButton.init
      fileinputSelector: $inputsContainer.find('.fileinput'),
      uploadButtonSelector: $inputsContainer.find('.uploadButton'),
      thumbs:
        container: $('.tracker-upload').find('.thumbs')
        selector: $('.tracker-upload').find('.fileIds')
        theme: window.TrackerAttachmentsTheme
        I18n: window.attachmentsI18n

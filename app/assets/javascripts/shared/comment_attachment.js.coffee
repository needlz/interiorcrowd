require ['RemovableThumbsTheme'], ->

  class @CommentAttachmentsTheme extends RemovableThumbsTheme

    createThumb: (fileInfo)->
      $container = super
      $enlargeButton = $container.find('.enlarge')
      $enlargeButton.attr('href', fileInfo.original_size_url)
      $container.find('.downloadButton').attr('href', fileInfo.download_url)
      $container.find('.size').text(humanFileSize(fileInfo.file_size))
      $container.find('.filename').text(fileInfo.name)
      PicturesZoom.init($enlargeButton)
      @removeUploadItem(fileInfo.original_name)
      $container

    onProgress: (file, progressPercents)->
      $container = @uploadThumb(file.name)
      $container.find('.progressbar .pointer').width("#{ progressPercents }%")

    addUploadItem: (file)->
      $template = @$container.find('.uploadingTemplate')
      $container = $template.clone()
      $container.removeClass('uploadingTemplate').addClass('uploadingThumb')
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
      $container.find('.progressbar').hide()
      $container.find('.processing').show()

    onFail: (file)->
      $container = @uploadThumb(file.name)
      $container.find('.progressbar').hide()
      $container.find('.processing').show().text('Uploading error')

    isUploadHalted: (fileInfo)->
      !@uploadThumb(fileInfo.original_name).length

  class @CommentAttachmentUploader

    @bindUploadButton: ($inputsContainer)->
      PicturesUploadButton.init
        fileinputSelector: $inputsContainer.find('.fileinput'),
        uploadButtonSelector: $inputsContainer.find('.uploadButton'),
        thumbs:
          container: $inputsContainer.find('.thumbs')
          selector: $inputsContainer.find('.fileIds')
          theme: window.CommentAttachmentsTheme
          I18n: window.attachmentsI18n
        uploading:
          onUploaded: (result)->
            $inputsContainer.find('.thumbs')
            result.files

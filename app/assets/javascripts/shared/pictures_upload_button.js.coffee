class @PicturesUploadButton
  @init: (options)->
    $(options.uploadButtonSelector).click (event)=>
      event.preventDefault()
      $(options.fileinputSelector).focus().click()

    $(options.fileinputSelector).initUploaderWithThumbs(
      thumbs:
        options.thumbs
      uploadify:
        start: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.uploading)
        stop: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.upload_button)
          options.uploading.onUploaded(event)
      single: options.single
    )

class @ExamplesUploader
  @init: ->
    PicturesUploadButton.init
      fileinputSelector: '.example-pictures #file_input',
      uploadButtonSelector: '.example-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: RemovableThumbsTheme
      I18n: I18n

class @SpacePicturesUploader
  @init: (i18n)->
    PicturesUploadButton.init
      fileinputSelector: '.space-pictures #file_input',
      uploadButtonSelector: '.space-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: RemovableThumbsTheme
      I18n: i18n

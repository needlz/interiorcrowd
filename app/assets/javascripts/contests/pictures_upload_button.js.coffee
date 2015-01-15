class @PicturesUploadButton
  @init: (options)->
    $(options.uploadButtonSelector).click =>
      $(options.fileinputSelector).click()

    $(options.fileinputSelector).initUploaderWithThumbs(
      thumbs:
        options.thumbs
      uploadify:
        start: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.uploading)
        stop: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.upload_button)
    )

class @ExamplesUploader
  @init: ->
    PicturesUploadButton.init
      fileinputSelector: '.example-pictures #file_input',
      uploadButtonSelector: '.example-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: 'new'
      I18n: I18n

class @SpacePicturesUploader
  @init: ->
    PicturesUploadButton.init
      fileinputSelector: '.space-pictures #file_input',
      uploadButtonSelector: '.space-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: 'new'
      I18n: I18n.photos

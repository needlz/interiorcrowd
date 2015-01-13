class @PicturesUploadButton
  @init: (fileinputSelector, uploadButtonSelector, thumbs)->
    $(uploadButtonSelector).click =>
      $(fileinputSelector).click()

    $(fileinputSelector).initUploaderWithThumbs(
      thumbs:
        thumbs
      uploadify:
        start: (event)=>
          $(uploadButtonSelector).text(I18n.uploading)
        stop: (event)=>
          $(uploadButtonSelector).text(I18n.upload_button)
    )

class @ExamplesUploader
  @init: ->
    PicturesUploadButton.init '.example-pictures #file_input',
      '.example-pictures .upload-button',
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: 'new'

class @SpacePicturesUploader
  @init: ->
    PicturesUploadButton.init '.space-pictures #file_input',
      '.space-pictures .upload-button',
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: 'new'

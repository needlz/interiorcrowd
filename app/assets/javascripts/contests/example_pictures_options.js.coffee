class @ExamplesUploader
  @fileinputSelector: '.example-pictures #file_input'
  @uploadButtonSelector: '.example-pictures .upload-button'

  @init: ->
    $(@uploadButtonSelector).click =>
      $(@fileinputSelector).click()
    $(@fileinputSelector).initUploaderWithThumbs(
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: 'new'
      uploadify:
        start: (event)=>
          $(@uploadButtonSelector).text(I18n.uploading)
        stop: (event)=>
          $(@uploadButtonSelector).text(I18n.upload_button)
    )

class @SpacePicturesUploader
  @fileinputSelector: '.space-pictures #file_input'
  @uploadButtonSelector: '.space-pictures .upload-button'

  @init: ->
    $(@uploadButtonSelector).click =>
      $(@fileinputSelector).click()

    $(@fileinputSelector).initUploaderWithThumbs(
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: 'new'
      uploadify:
        start: (event)=>
          $(@uploadButtonSelector).text(I18n.uploading)
        stop: (event)=>
          $(@uploadButtonSelector).text(I18n.upload_button)
    )

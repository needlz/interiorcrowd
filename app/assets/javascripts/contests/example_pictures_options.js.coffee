class @ExamplesUploader

  @init: ->
    $('.example-pictures .upload-button').click ->
      $(".example-pictures #file_input").click()
    $(".example-pictures #file_input").initUploaderWithThumbs(
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: 'new'
      uploadify:
        buttonText: I18n.upload_button
        removeTimeout: 5
    )


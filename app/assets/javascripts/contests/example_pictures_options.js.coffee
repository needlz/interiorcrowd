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
        start: (event)->
          $('.example-pictures .upload-button').text(I18n.uploading)
        stop: (event)->
          $('.example-pictures .upload-button').text(I18n.upload_button)
    )

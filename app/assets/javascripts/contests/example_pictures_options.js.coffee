class @ExamplesUploader

  @init: ->
    $(".example-pictures #file_input").initUploaderWithThumbs(
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
      uploadify:
        buttonText: "Upload"
        removeTimeout: 5
    )

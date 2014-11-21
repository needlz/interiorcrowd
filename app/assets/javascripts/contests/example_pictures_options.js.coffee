class @ExamplesUploader

  @init: ->
    $(".example-pictures #file_input").initUploaderWithThumbs(
      '#design_style_imge',
      {
        buttonText: "Upload"
        removeTimeout: 5
      }
    )

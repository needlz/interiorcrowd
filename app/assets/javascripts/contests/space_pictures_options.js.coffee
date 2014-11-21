class @SpacePicturesUploader

  @init: ->
    $(".space-pictures #file_input").initUploaderWithThumbs(
      '#design_space_image',
      {
        buttonText: "Upload"
        removeTimeout: 5
      }
    )

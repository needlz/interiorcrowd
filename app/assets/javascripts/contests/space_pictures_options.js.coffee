class @SpacePicturesUploader

  @init: ->
    $(".space-pictures #file_input").initUploaderWithThumbs(
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
      uploadify:
        buttonText: "Upload"
        removeTimeout: 5
    )

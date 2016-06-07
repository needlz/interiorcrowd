class @PicturesUploadButton
  @init: (options)->
    $formOrInput = $(options.fileinputSelector)
    if $formOrInput.prop('tagName') == 'FORM'
      $fileInput = $formOrInput.find('input[type=file]')
    else if $formOrInput.prop('tagName') == 'INPUT'
      $fileInput = $formOrInput

    $(options.uploadButtonSelector).click (event)=>
      event.preventDefault()
      $fileInput.focus().click()

    $formOrInput.initUploaderWithThumbs(
      thumbs:
        options.thumbs
      uploadify:
        start: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.uploading) if options.I18n
        onUploaded: (event)=> options.uploading.onDone?(event) if options.uploading
        stop: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.upload_button) if options.I18n
          options.uploading.onStop?(event) if options.uploading
      single: options.single
    )

class @ExamplesUploader
  @init: ->
    PicturesUploadButton.init
      fileinputSelector: '.example-pictures #file_input',
      uploadButtonSelector: '.example-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_style_image_id'
        theme: RemovableThumbsTheme
        dropZone: $('.design-style-options .example-pictures')
      I18n: I18n

class @SpacePicturesUploader
  @init: (i18n)->
    PicturesUploadButton.init
      fileinputSelector: '.space-pictures #file_input',
      uploadButtonSelector: '.space-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: RemovableThumbsTheme
        dropZone: $('.space-pictures .thumbs')
      I18n: i18n

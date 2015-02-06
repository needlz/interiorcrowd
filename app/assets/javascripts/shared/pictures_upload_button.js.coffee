class @PicturesUploadButton
  @init: (options)->
    $(options.uploadButtonSelector).click =>
      $(options.fileinputSelector).focus().click()

    $(options.fileinputSelector).initUploaderWithThumbs(
      thumbs:
        options.thumbs
      uploadify:
        start: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.uploading)
        stop: (event)=>
          $(options.uploadButtonSelector).text(options.I18n.upload_button)
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
        theme: 'new'
      I18n: I18n

class @SpacePicturesUploader
  @init: (i18n)->
    PicturesUploadButton.init
      fileinputSelector: '.space-pictures #file_input',
      uploadButtonSelector: '.space-pictures .upload-button',
      thumbs:
        container: '#image_display'
        selector: '#design_space_image_id'
        theme: 'new'
      I18n: i18n

class @ConceptBoardUploader
  @init: ->
    PicturesUploadButton.init
      fileinputSelector: '.concept-board #concept_picture',
      uploadButtonSelector: '.concept-board .upload-button',
      thumbs:
        container: '.concept-board .thumbs'
        selector: '#personal_picture_id'
        theme: 'new'
      I18n: I18n
      single: true
    @initSaveBtn()

  @initSaveBtn:->
    $('body').on('click', '.saveConceptBoard', @onSaveClick)
    $('body').on 'click', '.cancelConceptBoard', ->
      $(".initialImage").show()
      $('.editable-mode').remove()


  @onSaveClick: ()=>
    $.ajax(
      data: { contest_request: { image_id: $('#personal_picture_id').val() } }
      url: window.location.pathname
      type: 'PUT'
      dataType: "script"
      success: (data)=>
        newSource = $('.editable-mode img:last').attr('src')
        $(".initialImage img").attr('src', newSource)
        $(".initialImage").show()
        $('.editable-mode').remove()

    )


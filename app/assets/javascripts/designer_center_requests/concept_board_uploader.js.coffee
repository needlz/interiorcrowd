class @ConceptBoardUploader
  @idSelector: '#concept_board_picture_id'

  @init: (i18n)=>
    PicturesUploadButton.init
      fileinputSelector: '.concept-board #concept_picture',
      uploadButtonSelector: '.concept-board .upload-button',
      thumbs:
        container: '.concept-board .thumbs'
        selector: @idSelector
        theme: RemovableThumbsTheme
      I18n: i18n
      single: true
    @.initSaveBtn()


  @initSaveBtn:->
    $('body').on('click', '.saveConceptBoard', @onSaveClick)
    $('body').on 'click', '.cancelConceptBoard', =>
      @hideEditableBlock()

  @onSaveClick: ()=>
    id = $('.saveConceptBoard').attr('id')
    $.ajax(
      data: { contest_request: { image_id: $(@idSelector).val() } }
      url: "/designer_center/responses/#{id}"
      type: 'PUT'
      dataType: "script"
      success: (data)=>
        @changeImageSource()
        @hideEditableBlock()
        CommentsBlock.fitCommentsArea()
    )
  @hideEditableBlock: () ->
    $(".initialImage").show()
    $('.editable-mode').remove()

  @changeImageSource: ->
    newSource = $('.editable-mode img:last').attr('src')
    $(".initialImage img").attr({ src: newSource, alt: newSource})

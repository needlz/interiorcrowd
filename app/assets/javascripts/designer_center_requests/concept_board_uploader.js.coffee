class @ConceptBoardUploader
  @imageIdSelector: '#concept_board_picture_id'

  @init: (i18n)=>
    PicturesUploadButton.init
      fileinputSelector: '.concept-board #concept_picture',
      uploadButtonSelector: '.concept-board .upload-button',
      thumbs:
        selector: @imageIdSelector
        onRemoved: =>
          @saveChange()
          CommentsBlock.fitCommentsArea()
      I18n: i18n
      single: true
      uploading:
        onUploaded: (event)=>
          @saveChange()

  @saveChange: ()=>
    requestId = $('.response[data-id]').data('id')
    if requestId
      $.ajax(
        data: { lookbook_detail: { image_id: $(@imageIdSelector).val() } }
        url: "/designer_center/responses/#{ requestId }/lookbook_details"
        type: 'POST'
        success: (data)=>
          mixpanel.track('Concept board image updated', { contest_request_id: requestId })
          CommentsBlock.fitCommentsArea()
          $('#showcase').replaceWith(data)
          ConceptBoardShowcase.init()
      )

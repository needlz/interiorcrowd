class @ConceptBoardUploader
  @imageIdSelector: '#concept_board_picture_id'

  @init: (options = {})=>
    PicturesUploadButton.init
      fileinputSelector: '.concept-board #concept_picture',
      uploadButtonSelector: '.concept-board .upload-button',
      thumbs:
        selector: @imageIdSelector
        onRemoved: =>
          @saveChange()
          CommentsBlock.fitCommentsArea()
        theme: DefaultThumbsTheme
        dropZone: $('.concept-board.dropZone')
      I18n: options.i18n
      single: options.single
      uploading:
        onUploaded: (event)=>
          @saveChange(options.contestRequestId)

  @saveChange: (contestRequestId)=>
    if contestRequestId
      $.ajax(
        data: { lookbook_detail: { image_id: $(@imageIdSelector).val() } }
        url: "/designer_center/responses/#{ contestRequestId }/lookbook_details"
        type: 'POST'
        success: (data)=>
          mixpanel.track('Concept board image updated', { contest_request_id: contestRequestId })
          CommentsBlock.fitCommentsArea()
          $('#showcase').replaceWith(data)
          ConceptBoardShowcase.init()
      )
    else
      $.ajax(
        data: { image_ids: $(@imageIdSelector).val() }
        url: "/lookbook_details/preview"
        type: 'GET'
        success: (data)=>
          CommentsBlock.fitCommentsArea()
          $('#showcase').replaceWith(data)
          ConceptBoardShowcase.init()
      )

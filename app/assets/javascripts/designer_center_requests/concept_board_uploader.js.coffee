class @ConceptBoardUploader
  @imageIdSelector: '#concept_board_picture_id'

  @init: (i18n)=>
    PicturesUploadButton.init
      fileinputSelector: '.concept-board #concept_picture',
      uploadButtonSelector: '.concept-board .upload-button',
      thumbs:
        container: '.concept-board .thumbs'
        selector: @imageIdSelector
        theme: RemovableThumbsTheme
        onRemoved: =>
          @saveChange()
          CommentsBlock.fitCommentsArea()
      I18n: i18n
      single: true
      uploading:
        onUploaded: (event)=>
          @saveChange()

  @saveChange: ()=>
    alert "saveChange"
    requestId = $('.response[data-id]').data('id')
    if requestId
      $.ajax(
        data: { contest_request: { image_id: $(@imageIdSelector).val() } }
        url: "/designer_center/responses/#{ requestId }"
        type: 'PUT'
        dataType: "script"
        success: (data)=>
          mixpanel.track('Concept board image updated', { contest_request_id: requestId })
          CommentsBlock.fitCommentsArea()
      )

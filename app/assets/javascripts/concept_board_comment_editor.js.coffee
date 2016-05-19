class @ConceptBoardCommentEditor extends InlineEditor

  editButtonClassName: 'editButton'
  editButtonSelector: '.editButton'
  cancelButtonSelector: '.cancel'
  attributeIdentifierData: 'id'
  attributeSelector: '.commentContainer'
  sameEditCancelbutton: false

  getForm: (id, $button)->
    $formTemplate = $button.closest('.sidebarComments').find('.template .editForm')
    $controlsTemplate = $button.closest('.sidebarComments').find('.template .editControls')
    $attachmentsTemplate = $button.closest('.sidebarComments').find('.template .editAttachments')
    $comment = $button.closest(@attributeSelector)
    $editForm = $formTemplate.clone()
    $comment.find('.content').append($editForm)
    $comment.find('.editButton, .comment-time').hide()
    $comment.find('.controls').prepend($controlsTemplate.clone())
    @onEditFormRetrieved(id, $editForm.html())
    @initUploadTheme($comment, $attachmentsTemplate.clone(), $editForm)

    $comment.find('.controls .delete').confirm(
      text: 'Are you sure you want to delete that comment?'
      confirm: (button)=>
        @delete($comment)
      confirmButton: 'Yes I am'
      cancelButton: 'No'
      confirmButtonClass: 'btn-danger'
      cancelButtonClass: 'btn-default'
      dialogClass: 'modal-dialog modal-sm'
    )

  initUploadTheme: ($comment, $attachmentsTemplate, $editForm)->
    commentText = $comment.attr('data-text')
    $attachmentsTemplate.find('.text').val(commentText)
    $editForm.append($attachmentsTemplate)
    uploader = CommentAttachmentUploader.bindUploadButton($editForm)
    fileIds = []

    $comment.find('.thumbs .thumb[data-id]').each (i, element)=>
      $thumb = $(element)
      fileInfo = {}
      fileInfo.url = $thumb.find('.preview').attr('src')
      fileInfo.original_size_url = $thumb.find('.enlarge').attr('href')
      fileInfo.download_url = $thumb.find('.downloadButton').attr('href')
      fileInfo.file_size = $thumb.find('.size').text()
      fileInfo.name = $thumb.find('.filename').text()

      PicturesZoom.init($thumb.find('.enlarge'))

      $editThumb = uploader.thumbsTheme.createThumb(fileInfo)
      $editThumb
      $editForm.find('.thumbs').append($editThumb)

      thumbId = $thumb.attr('data-id')
      $editThumb.attr('data-id', thumbId)
      fileIds.push(thumbId)

    $comment.find('.fileIds').val(fileIds.join(','))

  bindEvents: ->
    super()
    @bindSaveClick()

  bindDeleteImageClick: ->
    $(document).on 'click', "#{@attributeSelector} .productListDeleteImage", (e)=>
      e.preventDefault()
      $container = $(e.target).parents(@attributeSelector)
      imageItemId = $container.data('id')
      $.ajax
        url: "/image_items/#{ imageItemId }"
        method: 'DELETE'
        success: (response)=>
          if response.destroyed
            @attributeElement(imageItemId).remove()

  bindSaveClick: ->
    $(document).on 'click', "#{ @attributeSelector } .controls .save:not(.disabled)", (event)=>
      event.preventDefault()
      $saveButton = $(event.target)
      $comment = $saveButton.parents(@attributeSelector)
      @update($comment)

  contestRequestId: ->
    $('.response[data-id]').attr('data-id') ||
      $('.concept-board[data-id]').attr('data-id') ||
      $('.designConcept[data-id]').attr('data-id')

  delete: ($comment)->
    requestId = @contestRequestId()
    commentId = $comment.attr('data-id')
    $.ajax(
      url: "/contest_requests/#{ requestId }/comments/#{ commentId }"
      type: 'DELETE'
      beforeSend: =>
        $comment.find('.controls .delete').addClass('disabled')
        $comment.find('.controls .delete').text('Deleting...')
        $comment.find('.controls .save').hide()
        $comment.find('.controls .cancel').hide()
        $comment.removeAttr('data-halted')
      success: (data)=>
        if data.destroyed_comment_id
          $comment.closest(".commentContainer[data-id=#{ data.destroyed_comment_id }]").remove()
      error: ->
        console.log('Server error when deleting comment')
    )

  onCancelClick: (event)=>
    super(event)
    $cancelButton = $(event.target)
    $comment = $cancelButton.closest(@attributeSelector)
    $comment.find('.editControls').remove()
    $comment.find('.editForm').remove()
    $comment.find('.editButton, .comment-time').show()
    $comment.attr('data-halted', '')

  update: ($comment)->
    text = $comment.find('.editForm .text').val()
    requestId = @contestRequestId()
    commentId = $comment.attr('data-id')
    attachmentIds = $comment.find('.fileIds').val().split(',')
    data = { comment: { text: text } }
    data.comment.attachment_ids = attachmentIds
    $.ajax(
      data: data
      url: "/contest_requests/#{ requestId }/comments/#{ commentId }"
      type: 'PATCH'
      beforeSend: =>
        $comment.find('.controls .save').addClass('disabled')
        $comment.find('.controls .save').text('Saving...')
        $comment.find('.controls .cancel').hide()
        $comment.removeAttr('data-halted')
      success: (data)=>
        return if $comment.is('[data-halted]')
        mixpanel.track 'Concept board comment edited'
        $comment.html(data.comment_html)
        @cancelEditing(commentId, $comment.find('.editControls .cancel'))
      error: ->
        console.log('Server error when saving comment')
      complete: ->
        $comment.find('.editControls .save').removeClass('disabled')
        $comment.find('.editControls .save').text('Save')
        $comment.find('.controls .cancel').show()
    )

class @ConceptboardComment

  @init: =>
    @i18n = MessagesI18n
    @textarea = $('.commentTextArea textarea')
    @$attachmentsInput = $('.commentTextArea input.fileIds')
    @attachmentThumbsSelector = '.commentTextArea .thumbs .thumb'
    @buttonSend = $('.comment-create')
    @buttonSend.on 'click', =>
      @create()

  @create: (path) ->
    text = @textarea.val()
    requestId = @textarea.attr('request')
    attachmentsIds = @$attachmentsInput.val().split(',')
    return if text == '' && !attachmentsIds[0]
    @makeRequest(text, requestId, attachmentsIds)

  @makeRequest: (text, requestId, attachmentsIds) ->
    $.ajax(
      data: { comment: { text: text, contest_request_id: requestId, attachments_ids: attachmentsIds } }
      url: "/contest_requests/#{requestId}/add_comment"
      type: 'POST'
      beforeSend: =>
        @buttonSend.text(@i18n.sending)
      success: (data)=>
        mixpanel.track 'Concept board commented'
        @newComment('allComents', data)
        @newComment('meComments', data)
        @prepareSection()
      error: ->
    )

  @prepareSection: ->
    @textarea.val('')
    @buttonSend.text(@i18n.send)
    @$attachmentsInput.val('')
    $(@attachmentThumbsSelector).remove()

  @newComment: (category, data) ->
    $category =  $("##{category}")
    hasComments = $category.find('.commentContainer:last').length > 0
    $newComment = $(data.comment_html)
    if hasComments
      $newComment.insertBefore($category.find('.commentContainer:first'))
    else
      $category.html($newComment)
    PicturesZoom.init($newComment.find('.enlarge'))

class @ConceptboardComment

  @init: =>
    @i18n = MessagesI18n
    @textarea = $('.commentTextArea textarea')
    @buttonSend = $('.comment-create')
    @buttonSend.on 'click', =>
      @.create()

  @create: (path) ->
    text = @textarea.val()
    return if text == ''
    requestId = @textarea.attr('request')
    @.makeRequest(text, requestId)

  @makeRequest: (text, requestId) ->
    $.ajax(
      data: { comment: {text: text, contest_request_id: requestId} }
      url: "/contest_requests/#{requestId}/add_comment"
      type: 'POST'
      beforeSend: =>
        @buttonSend.text(@i18n.sending)
      success: (data)=>
        mixpanel.track 'Concept board commented'
        @.newComment('allComents', data)
        @.newComment('meComments', data)
        @.prepareSection()
      error: ->
    )

  @prepareSection: ->
    @textarea.val('')
    @buttonSend.text(@i18n.send)

  @newComment: (category, data) ->
    $('.message-template .comment-text').text(data.comment.text)
    $('.message-template .comment-time').text(@i18n.now)
    $('.message-template .comment-username').text(@i18n.me)
    $category =  $("##{category}")
    hasComments = $category.find('.commentContainer:last').length > 0
    if hasComments
      $($('.message-template').html()).insertAfter($category.find(".commentContainer:last"))
    else
      $category.html($('.message-template').html())

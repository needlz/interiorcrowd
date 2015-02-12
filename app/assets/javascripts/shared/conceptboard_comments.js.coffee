class @ConceptboardComment

  @init: =>
    @i18n = MessagesI18n
    @textarea = $('.commentTextArea textarea')
    @buttonSend = $('.comment-create')
    @buttonSend.on 'click': =>
      @.create()

  @create: (path) ->
    text = @textarea.val()
    return if text == ''
    request = @textarea.attr('request')
    $.ajax(
      data: {  comment: {text: text, contest_request_id: request}  }
      url: "/contest_requests/#{request}/add_comment"
      type: 'POST'
      beforeSend: =>
        @buttonSend.text(@i18n.sending)
      success: (data)=>
        @textarea.val('')
        @.newComment('allComents', data)
        @buttonSend.text(@i18n.send)
      error: ->

    )
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

class @ConceptboardComment

  @init: =>
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
        @buttonSend.text('Sending..')
      success: (data)=>
        console.log(data)
        @textarea.val('')
        @.newComment('allComents', data)
        @buttonSend.text('Send')
      error: ->

    )
  @newComment: (category, data) ->
    $('.message-template .comment-text').text(data.comment.text)
    $('.message-template .comment-time').text(@.timeSince(data.comment.created_at))
    $('.message-template .comment-username').text('Me')
    $category =  $("##{category}")
    hasComments = $category.find('.commentContainer:last').length > 0
    if hasComments
      $($('.message-template').html()).insertAfter($category.find(".commentContainer:last"))
    else
      $category.html($('.message-template').html())



  @timeSince = (date) ->
    seconds = Math.floor((new Date() - new Date(date)) / 1000)
    interval = Math.floor(seconds / 31536000)
    return interval + " years ago"  if interval > 1
    interval = Math.floor(seconds / 2592000)
    return interval + " months ago"  if interval > 1
    interval = Math.floor(seconds / 86400)
    return interval + " days ago"  if interval > 1
    interval = Math.floor(seconds / 3600)
    return interval + " hours ago"  if interval > 1
    interval = Math.floor(seconds / 60)
    return interval + " minutes ago"  if interval > 1
    'now'
    #Math.floor(seconds) + " seconds ago"
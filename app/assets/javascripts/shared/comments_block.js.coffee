class @CommentsBlock
  @fitCommentsArea: ->
    imageHeight = parseInt($('.initialImage').css('height'))
    commentsHeight = (imageHeight - 323) || 300
    $('#scrollBoxComments').css('height', "#{commentsHeight}px")

class @CommentsBlock
  @fitCommentsArea: ->
    imageHeight = parseInt($('.initialImage').css('height'))
    commentsHeight = (imageHeight - 323) || 300
    $('#scrollBoxComments .tab-pane, #scrollBoxComments').css('height', "#{commentsHeight}px")
    $('#scrollBoxComments .tab-pane').customScrollBar();

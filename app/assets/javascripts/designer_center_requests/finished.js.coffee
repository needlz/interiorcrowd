class @DesignerFinishedContestRequestPage
  @commentsSelector: '.finalNote .comments'

  @init: ->
    $(window).resize(@fitHeight)
    $(@commentsSelector).customScrollBar()
    $(@commentsSelector).imagesLoaded().done =>
      @fitHeight()
    @fitHeight()
    $('#final-note-to-client, #final-note-to-designer').on('ajax:success', @onCommentSent)
    .on 'ajax:before', (e)=>
      $commentInput = $(e.target).find('[name="final_note[text]"]')
      @beforeSendComment($commentInput)

  @onCommentSent: (e, data) =>
    $container = $(e.target).closest('.finalNote')
    @updateComments($container, data.comments_html)
    @emptyInput($container)
    @updateCommentsCount($container, data.comments_count_text)

  @updateComments: ($commentsContainer, html)->
    $scrolledComments = $commentsContainer.find('.comments')
    $(@commentsSelector).mCustomScrollbar("destroy")
    $scrolledComments.html(html)
    $(@commentsSelector).customScrollBar()
    $(@commentsSelector).mCustomScrollbar("scrollTo", "bottom", {
      scrollInertia:200
    });
    @fitHeight()

  @emptyInput: ($container)->
    $container.find('[name="final_note[text]"]').val('')

  @updateCommentsCount: ($container, comments_count_text)->
    $container.find('.commentsCount').text(comments_count_text)

  @beforeSendComment: ($commentInput)->
    return false if trimedVal($commentInput) == ''

  @fitHeight: =>
    oneInRow = window.matchMedia('(max-width: 768px)').matches

    $(@commentsSelector).find('.comment').each (i, row)->
      maxHeight = 0
      parts = $(row).find('> div')
      parts.css('height', '')
      unless oneInRow
        parts.each ->
          if maxHeight < $(this).height()
            maxHeight = $(this).height()


        parts.css('height', maxHeight + 'px')

class ProductListMarks

  @imageMarksSelector: '.image-items .mark'

  @init: ()->
    $imageMarks = $(@imageMarksSelector)
    $imageMarks.click(@onMarkClick)

  @onMarkClick: (event)=>
    $markButton = $(event.target)
    @sendRequest($markButton)

  @sendRequest: ($button)->
    mark = $button.data('mark')
    id = $button.parents('.image-item').data('id')
    $.ajax(
      data: { id: id, image_item: { mark: mark } }
      url: "/image_items/#{id}/mark"
      type: 'PATCH'
      success: (data)=>
        @onRequestSuccess($button, data)
        mixpanel.track 'Product item or Similar style marked',
          { mark: mark, contest_request_id: $('.contest-request').data('id') }
    )

  @onRequestSuccess: ($button, data)->
    @toggleActivity($button)

  @toggleActivity: ($button)->
    $otherButtons = $button.parent().find('.mark')
    $otherButtons.removeClass('active')
    $button.addClass('active')

$ ->
  ProductListMarks.init()

class @EntriesMobilePagination

  @itemsContainerSelector: '.concept-board-items .items'

  @init: (loadMoreButtonSelector)->
    @loadMoreButtonSelector = loadMoreButtonSelector

    $(@loadMoreButtonSelector).click (event)=>
      event.preventDefault()
      $button = $(event.target)
      @requestNewPage($button.data('page'))

  @requestNewPage: (page)->
    $.ajax(
      url: '/client_center/concept_boards_page'
      data: { page: page }
      dataType: 'json'
      success: (response)=>
        $(@loadMoreButtonSelector).data('page', response.next_page)
        unless response.show_mobile_pagination
          $(@loadMoreButtonSelector).hide()
        $(@itemsContainerSelector).append(response.new_items_html)
    )

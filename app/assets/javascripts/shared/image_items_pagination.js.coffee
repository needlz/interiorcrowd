class @ImageItemsPagination

  @init: ($imageItemsContainer)->
    $imageItemsContainer.on 'click', '.imageItemsPagination .pageLink', (event)->
      event.preventDefault()
      $link = $(event.target)
      $scope = $link.closest('.imageItems[data-scope]')
      scope = $scope.data('scope')
      params = {}
      pagination_param = "#{ scope }_page"
      params[pagination_param] = $link.data('page')
      id = $('#contest-data').data('id')
      $scope.find('.items').fadeTo('fast', 0.5)
      url = $scope.data('url')

      $.get url, params, (data)->
        $scope.html(data)
        history.pushState({}, '', $link.attr('href'))
        ImageItemsTextFolding.init()

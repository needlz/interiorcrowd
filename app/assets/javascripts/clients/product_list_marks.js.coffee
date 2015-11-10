class ProductListMarks

  @imageMarksSelector: '.productRadio input[type="radio"]'

  @init: ()->
    $imageMarks = $(@imageMarksSelector)
    $imageMarks.change(@onMarkClick)
    $imageMarks.on 'ajax:success', (e, data)->
      mixpanel.track 'Product item or Similar style marked',
        { mark: mark, contest_request_id: $('.concept-board').data('id') }

  @onMarkClick: (event)=>
    $form = $(event.target).closest('form')
    @sendRequest($form)

  @sendRequest: ($form)->
    $form.trigger('submit.rails')

$ ->
  ProductListMarks.init()
